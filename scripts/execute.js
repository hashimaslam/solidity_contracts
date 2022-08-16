(async function () {
  try {
    const addr = "0x0954287389EF31766f6556A653B1129390FC50FC";
    const provider = new ethers.providers.Web3Provider(web3Provider);
    const signer = provider.getSigner();
    const metadata = JSON.parse(
      await remix.call(
        "fileManager",
        "getFile",
        "browser/artifacts/Wrapper.json"
      )
    );
    let contract = new ethers.Contract(addr, metadata.abi, signer);
    let lp = await contract.getData();
    //console.log(lp,"from lp");

    let tx = await contract.depositToPool(
      "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD",
      ethers.utils.parseUnits("55", 18),
      "0x0034225450ad6a08c39c32F6dE281c71B237392A",
      0
    );
    let pool = await contract.getPoolAddress();
    console.log(pool, "from pool");
    //console.log(tx);
  } catch (e) {
    console.log(e.message);
  }
})();
