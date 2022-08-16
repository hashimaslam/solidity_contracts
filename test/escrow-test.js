const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { waffle } = require("hardhat");
const provider = waffle.provider;

describe("Escrow", function () {
  const wallets = provider.getWallets();
  const [user_A, user_B] = wallets;

  let escrow;
  beforeEach(async () => {
    const Escrow = await ethers.getContractFactory("Escrow");
    escrow = await Escrow.deploy(user_A.address);
    await escrow.deployed();
  });

  it("Balance should be added to the contract", async () => {
    const value = BigNumber.from("1000000000000");
    await escrow.depositAndAssign(user_B.address, {
      value: value,
    });
    expect(await escrow.getbalance()).to.eql(value);
    expect(await escrow.currWorkflow()).to.eql(1);
  });

  it("Should be called only by user_B", async () => {
    await expect(escrow.confirmWorkDone()).to.be.revertedWith(
      "only user_B can confirm the work"
    );
  });
  it("Should chnage the workflow to 2", async () => {
    const value = BigNumber.from("1000000000000");
    await escrow.depositAndAssign(user_B.address, {
      value: value,
    });
    await escrow.connect(user_B).confirmWorkDone();
    expect(await escrow.currWorkflow()).to.eq(2);
    await escrow.confirmAndPay();
    const balance = BigNumber.from(0);
    expect(await escrow.getbalance()).to.eq(BigNumber.from("0"));
  });
});
