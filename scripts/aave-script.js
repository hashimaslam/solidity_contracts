const hre = require("hardhat");
const { waffle, ethers } = require("hardhat");
const provider = waffle.provider;
const { BigNumber } = require("ethers");

async function main() {
  const AaveWrapper = await ethers.getContractFactory("AaveWrapper");
  const aaveWrapper = await AaveWrapper.deploy();
  await aaveWrapper.deployed();

  await aaveWrapper.getUserData();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
