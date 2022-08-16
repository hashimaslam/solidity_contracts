const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { waffle } = require("hardhat");
const provider = waffle.provider;
let abi = require("../artifacts/contracts/Sample2.sol/Delta.json");
describe("Sample Test", function () {
  const wallets = provider.getWallets();
  const [user_A, user_B, user_C] = wallets;

  let contA;
  let contB;
  let contC;
  let contD;
  beforeEach(async () => {
    const ContA = await ethers.getContractFactory("Alpha");
    contA = await ContA.deploy();
    const ContC = await ethers.getContractFactory("Cat");
    contC = await ContC.deploy();
    const ContD = await ethers.getContractFactory("Delta");
    contD = await ContD.deploy();
    //await ContA.deployed();

    const ContB = await ethers.getContractFactory("Beta");
    contB = await ContB.deploy();

    //await ContB.deployed();
  });

  it("Deploy contracts properly", async () => {
    console.log(contA.address, "from A");
    console.log(contB.address, "from A");
    await contA.setVars(contB.address, 124);
    console.log(await contA.setVars(contB.address, 124));
    console.log(await contA.num());

    const data = await contD.delegatecallSetN(contC.address, 12);
    let abiCoder = new ethers.utils.Interface(abi);
    let result = await abiCoder.decodeFunctionData("delegatecallSetN", data);
    console.log(result);
    //child2 = await ethers.getContractAt("Escrow", children[1]);
  });
  // it("Should give value", async () => {
  //   console.log(await child1.claimAmount());
  // });
});
