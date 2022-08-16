(async function () {
  try {
    const metadata = JSON.parse(
      await remix.call(
        "fileManager",
        "getFile",
        "browser/artifacts/Wrapper.json"
      )
    );
    // the variable web3Provider is a remix global variable object
    const signer = new ethers.providers.Web3Provider(web3Provider).getSigner();
    // Create an instance of a Contract Factory
    let factory = new ethers.ContractFactory(
      metadata.abi,
      metadata.data.bytecode.object,
      signer
    );
    // Notice we pass the constructor's parameters here
    let contract = await factory.deploy(
      "0x88757f2f99175387aB4C6a4b3067c77A695b0349"
    );
    // The address the Contract WILL have once mined
    console.log(contract.address);
    // The transaction that was sent to the network to deploy the Contract
    console.log(contract.deployTransaction.hash);
    // The contract is NOT deployed yet; we must wait until it is mined
    await contract.deployed();
    // Done! The contract is deployed.
    console.log("contract deployed");
  } catch (e) {
    console.log(e.message);
  }
})();
