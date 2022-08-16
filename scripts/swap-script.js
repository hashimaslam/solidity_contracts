const hre = require("hardhat");

const { waffle, ethers } = require("hardhat");
const provider = waffle.provider;
const { BigNumber } = require("ethers");
const uniswapAbi = require("../abi/uniswapRouter.json");
const erc20Abi = require("../abi/ERC20abi.json");

async function main() {
  const signer = await ethers.provider.getSigner();
  let address = await signer.getAddress();
  let balance = await signer.getBalance();
  const contract = new ethers.Contract(
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    uniswapAbi,
    signer
  );
  const Erc20 = new ethers.Contract(
    "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa",
    erc20Abi,
    signer
  );

  let amountIn = ethers.utils.parseUnits("1", 18);
  //approve
  const transfer = await Erc20.approve(
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    amountIn
  );
  transfer.wait();
  //   let wethAddr = await contract.WETH();
  console.log(amountIn.toString());
  let amountOut = await contract.getAmountsOut(amountIn.toString(), [
    "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa",
    "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b",
  ]);
  amountOut.map((item) => {
    console.log(item.toString());
  });
  //   let wethContract = new ethers.getContractAt()

  let trade = await contract.swapExactTokensForTokens(
    amountIn.toString(),
    amountOut[1],
    [
      "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa",
      "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b",
    ],
    address,
    Math.floor(Date.now() / 1000) + 60 * 10,
    {
      gasLimit: 10000000,
    }
  );
  trade.wait();
  console.log(trade, "from trade");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
