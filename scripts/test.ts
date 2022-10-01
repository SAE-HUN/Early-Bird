import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";


  async function balanceLogging(earlyBird:any, owner:any, erc20:any){
    const beforeOwnerBalance = await erc20.balanceOf(owner.address);
    const beforeContractBalance = await erc20.balanceOf(earlyBird.address);
    
    console.log('Balance')
    console.log('  - Owner:', beforeOwnerBalance)
    console.log('  - Contract:', beforeContractBalance)
    console.log();
  }

async function main() {
    const [owner, otherAccount] = await ethers.getSigners();
    const erc20 = await ethers.getContractAt('GLDToken', '0xEf2d70E4a7297B31A1245253904a4cA975CA7e12');
    const earlyBird = await ethers.getContractAt('EarlyBird', '0x6c9084633AA7DB67f93DcC71ed0F34d956643Dd0');
    
  // await erc20.approve(earlyBird.address, '100000000000000000000000000000000');
  // console.log('Allowance:', await erc20.allowance(owner.address, earlyBird.address))
  
  // await balanceLogging(earlyBird, owner, erc20);

  // console.log('Registering challenge...');
  // const challenge = {depositAmount: "10000000000", startTimestamp: "1664755200", endTimestamp: "1665360000", wakeUpTimestamp: "32400", weekdays: [true, false, true, false, true, false, false]};
  // await earlyBird.registerChallenge(challenge);
  // console.log('Registered!');
  // console.log('Check Registeration:', await earlyBird.isUserChallenging(owner.address));
  // console.log();

  // await balanceLogging(earlyBird, owner, erc20);

  // console.log('Start to prove')
  // for(let i = 0; i < 7; i++){
    // await time.increaseTo(1665705600)
    // await time.increase(32300)
    // console.log(await time.latest())
    // await earlyBird.submitProof();
  // }
  
  // await balanceLogging(earlyBird, owner, erc20);

  // await earlyBird.getRefund();

  // await balanceLogging(earlyBird, owner, erc20);
  // console.log('Check challenge end:', await earlyBird.isUserChallenging(owner.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
