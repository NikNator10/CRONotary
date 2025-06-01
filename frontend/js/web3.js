let provider;
let signer;
let userAddress;

async function connectWallet() {
  if (!window.ethereum) {
    alert("MetaMask not installed");
    return null;
  }  

    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();
    return userAddress;
}

function getSigner() {
  return signer;
}

function getProvider() {
  return provider;
}

function getUserAddress() {
  return userAddress;
}
