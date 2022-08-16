(async function () {
  try {
    const addr = "0xFcd8777cc07160379dCE16B442932dBD801629E9";
    const BORROW_AMOUNT = "10000000000000000000";
    const metadata = JSON.parse(
      await remix.call(
        "fileManager",
        "getFile",
        "browser/FlashLoan/artifacts/TestFlashLoan.json"
      )
    );
    const erc20Meta = JSON.parse(
      await remix.call(
        "fileManager",
        "getFile",
        "browser/artifacts/IERC20.json"
      )
    );
    // the variable web3Provider is a remix global variable object
    const signer = new ethers.providers.Web3Provider(web3Provider).getSigner();
    let contract = new ethers.Contract(
      "0xFcd8777cc07160379dCE16B442932dBD801629E9",
      metadata.abi,
      signer
    );
    let ERC20 = new ethers.Contract(
      "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
      erc20Meta.abi,
      signer
    );

    let balance = await ERC20.balanceOf(addr);
    console.log(balance.toString());
    const tx = await contract.testFlashLoan(
      "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
      BORROW_AMOUNT
    );
    await tx.wait();
    console.log(tx);
    for (const log of tx.logs) {
      console.log(log.args.message, log.args.val.toString());
    }
  } catch (e) {
    console.log(e.message);
  }
})();
