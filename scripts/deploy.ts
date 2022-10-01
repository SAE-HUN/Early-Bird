import { ethers } from "hardhat";

async function main() {
  const ERC20 = await ethers.getContractFactory("Token");
  const erc20 = await ERC20.deploy('10000000000000000000000000000000000000000000');
  console.log('erc20', erc20.address);

  const EarlyBird = await ethers.getContractFactory("EarlyBird");
  const earlyBird = await EarlyBird.deploy('0x5b1610b920d0C6E7176b8292CB1f083496Fe1257', erc20.address);
  console.log(earlyBird.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
