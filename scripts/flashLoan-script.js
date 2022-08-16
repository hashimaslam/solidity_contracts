const hre = require("hardhat");

const { waffle, ethers } = require("hardhat");
const provider = waffle.provider;
const { BigNumber } = require("ethers");

async function main() {
  const wallets = provider.getWallets();
  const [user_A, user_B, user_C] = wallets;
  //   await network.provider.request({
  //     method: "hardhat_impersonateAccount",
  //     params: ["0x0034225450ad6a08c39c32F6dE281c71B237392A"],
  //   });
  //   await network.provider.send("hardhat_setBalance", [
  //     "0x0d2026b3EE6eC71FC6746ADb6311F6d3Ba1C000B",
  //     "0x10000000000",
  //   ]);
  //   let signer = await ethers.getSigner(
  //     "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266"
  //   );
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0x364d6D0333432C3Ac016Ca832fb8594A8cE43Ca6"],
  });
  // let ERC20 = new ethers.Contract(
  //   "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
  //   erc20Abi,
  //   user_A
  // );
  let balance = await user_A.getBalance();

  console.log(balance.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
