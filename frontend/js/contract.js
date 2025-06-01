let contract;
let contractAddress = "0x4cE50762FF9BEEf5c36B72Aa8487F8F4341D9da3";

async function loadContract() {
  const response = await fetch("js/CRONotaryABI.json");
  const abi = await response.json();

  const signer = getSigner();
  const provider = new ethers.providers.JsonRpcProvider("https://evm-t3.cronos.org");

  const signerOrProvider = signer || provider;

  contract = new ethers.Contract(contractAddress, abi, signerOrProvider);
  return contract;
}

