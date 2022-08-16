// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

const hre = require("hardhat");
const { waffle } = require("hardhat");
const provider = waffle.provider;
const { BigNumber } = require("ethers");

async function main() {
  // const wallets = provider.getWallets();
  // const [owner, participant1, participant2, participant3] = wallets;
  // const Auction = await hre.ethers.getContractFactory("Auction");
  // const auction = await Auction.deploy(
  //   "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
  //   10,
  //   120,
  //   "SampleNFT",
  //   "SMNFT",
  //   "https://jsonkeeper.com/b/T7NP"
  // );

  // await auction.deployed();
  // const value = BigNumber.from("2000000000000");
  // let tx = await auction.connect(participant1).placeBid({ value: value });
  // await tx.wait();

  // console.log("Auction deployed to:", auction.address);
  // const Escrow = await hre.ethers.getContractFactory("Escrow");
  // const escrow = await Escrow.deploy();
  // await escrow.deployed();
  // const Factory = await hre.ethers.getContractFactory("EscrowFactory");
  // const factory = Factory.deploy(escrow.address);
  // console.log((await factory).address);
  // console.log(escrow.address);
  const ClaimMoneyV1 = await ethers.getContractFactory("ClaimMoneyV1");
  claimMoneyV1 = await ClaimMoneyV1.deploy();
  await claimMoneyV1.deployed();

  const ClaimMoneyV2 = await ethers.getContractFactory("ClaimMoneyV2");
  claimMoneyV2 = await ClaimMoneyV2.deploy();
  await claimMoneyV2.deployed();

  const Factory = await ethers.getContractFactory("MoneyFactory");
  factory = await Factory.deploy();
  await factory.deployed();
  const MoneyProxy = await ethers.getContractFactory("MoneyProxy");
  moneyProxy = await MoneyProxy.deploy();

  await moneyProxy.deployed();

  await factory.addMaster(moneyProxy.address);
  await factory.addImplementationAddr(claimMoneyV1.address);
  console.log(factory.address);
  console.log(await factory.masterContract());
  console.log(await factory.implementation());
  await factory.createChild();
  await factory.createChild();
  const children = await factory.getChildren();
  console.log(children);
  child1 = await ethers.getContractAt("MoneyProxy", children[0]);
  console.log(await child1.factory());
  console.log(await child1.amount());
  // console.log(await child1.sample());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
