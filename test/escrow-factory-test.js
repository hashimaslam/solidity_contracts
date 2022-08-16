const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { waffle } = require("hardhat");
const provider = waffle.provider;

describe("Escrow", function () {
  const wallets = provider.getWallets();
  const [user_A, user_B, user_C] = wallets;

  let escrow;
  let factory;
  let Escrow;
  let child1;
  let child2;
  const value1 = BigNumber.from("1000000000000");
  const value2 = BigNumber.from("3000000000000");
  beforeEach(async () => {
    Escrow = await ethers.getContractFactory("Escrow");
    escrow = await Escrow.deploy();
    await escrow.deployed();
    const Factory = await ethers.getContractFactory("EscrowFactory");
    factory = await Factory.deploy(escrow.address);
    await factory.deployed();
  });
  it("Should create childs", async () => {
    await factory.createChild(user_A.address);
    await factory.createChild(user_C.address);
    const children = await factory.getChildren();
    child1 = await ethers.getContractAt("Escrow", children[0]);
    child2 = await ethers.getContractAt("Escrow", children[1]);
  });
  it("Child contract user_A should match", async () => {
    expect(user_A.address).to.eq(await child1.user_A());
    expect(user_C.address).to.eq(await child2.user_A());
  });
  it("Child contract user_B should match", async () => {
    await child1.depositAndAssign(user_B.address, { value: value1 });
    await child2
      .connect(user_C)
      .depositAndAssign(user_B.address, { value: value2 });
    expect(await child1.user_B()).to.eq(user_B.address);
    expect(await child2.user_B()).to.eq(user_B.address);
  });
  it("Balance Should Match", async () => {
    expect(await child1.getbalance()).to.eq(value1);
    expect(await child2.getbalance()).to.eq(value2);
  });
  it("");
});
