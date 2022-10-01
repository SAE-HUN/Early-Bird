// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./IERC20.sol";

contract EarlyBird {
    event ChallengeRegistered(address indexed user, Challenge challenge);
    event Refund(
        address indexed user,
        Challenge challenge,
        bool challengeResult
    );
    event Prove(address indexed user, uint256 timestamp);

    struct Challenge {
        uint256 depositAmount;
        uint32 startTimestamp;
        uint32 endTimestamp;
        uint32 wakeUpTimestamp;
        /* Note: 
            1. it should be stored as GMT weekday.
            2. Index 0 represents monday.
        */
        bool[7] weekdays;
    }

    struct Proof {
        uint128 lastSubmitTime;
        uint128 count;
    }

    mapping(address => Challenge) public userChallenge;
    mapping(address => bool) public isUserChallenging;
    mapping(address => Proof) public userProof;

    address public owner;
    IERC20 public challengeToken;

    constructor(address _owner, IERC20 _challengeToken) {
        owner = _owner;
        challengeToken = _challengeToken;
    }

    function registerChallenge(Challenge memory challenge) external {
        Challenge memory _challenge = userChallenge[msg.sender];
        if (
            isUserChallenging[msg.sender] &&
            _challenge.endTimestamp < block.timestamp
        ) {
            _getRefund(msg.sender);
        }
        _registerChallenge(challenge, msg.sender);
    }

    function _registerChallenge(Challenge memory challenge, address user)
        internal
    {
        require(!isUserChallenging[user], "User is already challenging");
        require(
            challenge.startTimestamp % 1 days == 0,
            "Start time is day unit"
        );
        require(challenge.endTimestamp % 1 days == 0, "End time is day unit");
        require(
            (challenge.endTimestamp - challenge.startTimestamp) % 1 weeks == 0,
            "Period is week unit"
        );
        require(
            challenge.startTimestamp < challenge.endTimestamp,
            "Invalid Period"
        );
        require(challenge.wakeUpTimestamp < 1 days, "Invalid Wake up time");

        userChallenge[user] = challenge;
        isUserChallenging[user] = true;

        console.log(
            user,
            address(this),
            challengeToken.allowance(user, address(this))
        );
        challengeToken.transferFrom(
            user,
            address(this),
            challenge.depositAmount
        );

        emit ChallengeRegistered(user, challenge);
    }

    function getRefund() external {
        _getRefund(msg.sender);
    }

    function _getRefund(address user) internal {
        Challenge memory challenge = userChallenge[user];
        require(isUserChallenging[user], "User isn't challenging");
        require(
            challenge.endTimestamp < block.timestamp,
            "Challenge not end yet"
        );

        bool challengeResult = isChallengeSuccess(challenge, userProof[user]);
        if (challengeResult) {
            challengeToken.transfer(user, challenge.depositAmount);
        }

        userProof[user] = Proof(0, 0);
        isUserChallenging[user] = false;

        emit Refund(user, challenge, challengeResult);
    }

    function submitProof() public {
        Challenge memory challenge = userChallenge[msg.sender];
        require(isUserChallenging[msg.sender], "User isn't challenging");
        require(
            challenge.startTimestamp <= block.timestamp,
            "Challenge not start"
        );
        require(block.timestamp <= challenge.endTimestamp, "Challenge end");

        uint256 today = (block.timestamp / 1 days) * 1 days;
        uint256 weekday = (((today / 1 days) % 7) + 3) % 7;
        console.log(
            today,
            weekday,
            challenge.weekdays[weekday],
            block.timestamp
        );
        require(challenge.weekdays[weekday], "Today is not challenge day");
        require(
            today + challenge.wakeUpTimestamp - 10 minutes <= block.timestamp,
            "Not wake up time yet"
        );
        require(
            block.timestamp <= today + challenge.wakeUpTimestamp,
            "You wake up lately"
        );

        Proof memory proof = userProof[msg.sender];
        require(
            (proof.lastSubmitTime / 1 days) * 1 days != today,
            "Only 1submit per 1day"
        );

        proof.count += 1;
        proof.lastSubmitTime = uint128(block.timestamp);
        userProof[msg.sender] = proof;

        emit Prove(msg.sender, block.timestamp);
    }

    function isChallengeSuccess(Challenge memory challenge, Proof memory proof)
        public
        pure
        returns (bool)
    {
        uint256 criteria = 0;
        for (uint256 i = 0; i < challenge.weekdays.length; i++) {
            if (challenge.weekdays[i]) {
                criteria += 1;
            }
        }

        criteria *=
            (challenge.endTimestamp - challenge.startTimestamp) /
            1 weeks;
        criteria = (criteria * 80) / 100;
        return proof.count >= criteria;
    }

    function getUserChallenge() public view returns (Challenge memory) {
        return userChallenge[msg.sender];
    }
}
