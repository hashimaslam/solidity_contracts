const hre = require("hardhat");
const { waffle, ethers } = require("hardhat");
const provider = waffle.provider;
const { BigNumber } = require("ethers");
const lendingPoolProviderAbi = require("../abi/lendingPoolProviderABI.json");
const lendingPoolAbi = require("../abi/lendingPoolABI.json");
const erc20Abi = require("../abi/ERC20abi.json");
const isV3 = false;

let lendingPoolAddressProvider = isV3
  ? "0xBA6378f1c1D046e9EB0F538560BA7558546edF3C"
  : "0x88757f2f99175387aB4C6a4b3067c77A695b0349";

async function main() {
  const wallets = await ethers.provider.getSigner();
  let address = await wallets.getAddress();
  let balance = await wallets.getBalance();

  let LPAProvider = await ethers.getContractAt(
    lendingPoolProviderAbi,
    lendingPoolAddressProvider
  );
  let poolAddress = await LPAProvider.getLendingPool();
  console.log(poolAddress);

  let LendingPool = new ethers.Contract(poolAddress, lendingPoolAbi, wallets);
  let LendingPool2 = new ethers.Contract(
    poolAddress,
    lendingPoolAbi,
    ethers.provider
  );
  let ERC20 = new ethers.Contract(
    "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
    erc20Abi,
    wallets
  );
  let bal = await ERC20.balanceOf(address);
  await ERC20.approve(poolAddress, ethers.utils.parseUnits("400", 18));

  depositing;
  await LendingPool.deposit(
    "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
    ethers.utils.parseUnits("55", 18),
    address,
    0
  );
  let result = await LendingPool2.getUserAccountData(address);

  console.log(result);
  // let contract = new ethers.Contract("0x0d4A26F830cF8D3c2Bb345bBc9b98376e6A61f09")
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
