let contract;
let contractAddress = "0x4cE50762FF9BEEf5c36B72Aa8487F8F4341D9da3";

async function loadContract() {
  const response = await fetch("js/CRONotaryABI.json");
  const abi = await response.json();

  const signer = getSigner();

  contract = new ethers.Contract(contractAddress, abi, signer);
  return contract;
}
