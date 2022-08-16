require("@nomiclabs/hardhat-waffle");
require("solidity-coverage");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-ethers");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "^0.4.23",
      },
      {
        version: "0.6.12",
      },
      {
        version: "0.8.4",
      },
      {
        version: "^0.8.6",
      },
    ],
    overrides: {
      "node_modules/@aave/protocol-v2/contracts/interfaces/ILendingPool.sol": {
        version: "0.6.12",
        settings: {},
      },
    },
  },
  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/woNv9ehftboTaIVHXVSZXK_U5MaMjCol",
      accounts: [
        "0x8ce0efba224d4bfaba463d4d5d5e32bea90b1bae5356ac15aa31dd0e65b12168",
      ],
    },
    kovan: {
      url: "https://eth-kovan.alchemyapi.io/v2/nZroG-6TDEWXvvAOeYABBy7xfOQ_LNj9",
      accounts: [
        "0x8ce0efba224d4bfaba463d4d5d5e32bea90b1bae5356ac15aa31dd0e65b12168",
      ],
    },
    hardhat: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/N0TPge2CD8PjyYICqCYhn_8-haViTRqu",
      },
    },
  },
};
