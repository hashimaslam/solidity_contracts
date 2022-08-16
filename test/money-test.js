const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { waffle } = require("hardhat");
const provider = waffle.provider;

describe("Money streaming", function () {
  const wallets = provider.getWallets();
  const [user_A, user_B, user_C] = wallets;

  let factory;
  let claimMoneyV1;
  let claimMoneyV2;
  let moneyProxy;
  let child1;
  let child2;
  //   const value1 = BigNumber.from("1000000000000");
  //   const value2 = BigNumber.from("3000000000000");
  beforeEach(async () => {
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
  });

  it("Deploy contracts properly", async () => {
    await factory.addMaster(moneyProxy.address);
    await factory.addImplementationAddr(claimMoneyV2.address);
    console.log(factory.address, "from factory address");
    console.log(await factory.masterContract());
    console.log(await factory.implementation());
    await factory.createChild();
    await factory.createChild();
    const children = await factory.getChildren();
    console.log(children);
    child1 = await ethers.getContractAt("MoneyProxy", children[0]);
    console.log(await child1.factory(), "from factory");
    //await child1.fallback();
    let encoded = claimMoneyV2.interface.encodeFunctionData("calimMoney");

    // let getBalance = claimMoneyV1.interface.encodeFunctionData("balanceOf", [
    //   user_A.address,
    // ]);
    // console.log(encoded);
    await child1.connect(user_A).fallback({ data: encoded });
    //let balance = await child1.connect(user_A).fallback({ data: getBalance });
    console.log(await child1.amount());
    // console.log(
    //   claimMoneyV1.interface.decodeFunctionData("balanceOf", balance.data),
    //   "from balance"
    // );
    // console.log(await claimMoneyV1.balanceOf(user_A.address), "fom bbl");
  });
});
