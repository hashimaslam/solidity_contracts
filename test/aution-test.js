const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { waffle } = require("hardhat");
const provider = waffle.provider;

describe("Aution Tests", function () {
  const wallets = provider.getWallets();
  const [owner, participant1, participant2, participant3] = wallets;

  let auction;
  beforeEach(async () => {
    const Auction = await ethers.getContractFactory("Auction");
    auction = await Auction.deploy(owner.address, 10, 40);
    await auction.deployed();
  });

  it("Should be able to place a bid ", async () => {
    const value = BigNumber.from("2000000000000");
    await auction.connect(participant1).placeBid({ value: value });
    expect(await auction.owner()).to.eq(
      owner.address,
      "Owner address should be correct"
    );
    expect(await auction.fundsByBidder(participant1.address)).to.eq(
      value,
      "Value should be matched properly"
    );
    const value2 = BigNumber.from("3000000000000");
    await auction.connect(participant2).placeBid({ value: value2 });
    expect(await auction.connect(participant2).getHighestBid()).to.eq(
      value2,
      "Highest Bid should match the highest one"
    );
    expect(await auction.connect(participant2).highestBindingBid()).to.eq(
      BigNumber.from("2000000000010"),
      "Highest BindingBid should be incremented with 10"
    );
  });

  it("Should throw errors as expected", async () => {
    const value = BigNumber.from("0");
    await expect(
      auction.connect(participant1).placeBid({ value: value })
    ).to.be.revertedWith("Value should not be Zero");
    await expect(auction.placeBid({ value: value })).to.be.revertedWith(
      "owner can't have access"
    );
    await auction.cancelAuction();
    const value1 = BigNumber.from("3000000000000");
    expect(await auction.canceled()).to.eq(true);
    await expect(
      auction.connect(participant2).placeBid({ value: value1 })
    ).to.be.revertedWith("Aution cancelled");
  });

  it("Bid price should be higher then previous highestbid", async () => {
    const value1 = BigNumber.from("3000000000000");
    const value2 = BigNumber.from("2000000000000");
    const value3 = BigNumber.from("1000000000000");
    await auction.connect(participant1).placeBid({ value: value1 });
    await auction.connect(participant2).placeBid({ value: value2 });
    await expect(
      auction.connect(participant3).placeBid({ value: value3 })
    ).to.be.revertedWith("New bid should be higher");
  });

  it("Should withdraw amounts properly", async () => {
    const value1 = BigNumber.from("3000000000000");
    const value2 = BigNumber.from("2000000000000");
    await auction.connect(participant1).placeBid({ value: value1 });
    await auction.connect(participant2).placeBid({ value: value2 });
    await expect(auction.withdraw()).to.be.revertedWith(
      "Aution Not Ended or Cancelled"
    );
    await auction.cancelAuction();
    const available = await auction.fundsByBidder(participant1.address);
    console.log(available);
    const balance =
      ethers.utils.formatEther(available) +
      ethers.utils.formatEther(
        await ethers.provider.getBalance(participant1.address)
      );
    const partBalance = ethers.provider.getBalance(participant1.address);
    console.log(await ethers.utils.formatEther(balance));
    //console.log(await ethers.utils.formatEther(partBalance));
    await auction.connect(participant1).withdraw();

    //expect(participant1.balance).to.eq(BigNumber.from(balance));
  });
});
