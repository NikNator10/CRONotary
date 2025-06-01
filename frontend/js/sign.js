document.addEventListener("DOMContentLoaded", async () => {
  const connectBtn = document.getElementById("connectBtn");
  const walletAddressDisplay = document.getElementById("walletAddress");
  const signBtn = document.getElementById("signBtn");
  const fileInput = document.getElementById("fileInput");
  const status = document.getElementById("status");

  let fileHashHex = null;

  connectBtn.addEventListener("click", async () => {
    const address = await connectWallet();
    if (address) {
      walletAddressDisplay.innerText = "Wallet-Address: " + address;
      connectBtn.innerText = "Wallet connected";
      connectBtn.disabled = true;
      signBtn.disabled = false;
    }
  });

  fileInput.addEventListener("change", async (event) => {
    const file = event.target.files[0];
    if (file) {
      fileHashHex = await sha256FromFile(file);
      status.innerText = `SHA-256 Hash: ${fileHashHex}`;
    }
  });

  signBtn.addEventListener("click", async () => {
    if (!fileHashHex) {
      status.innerText = "Please select a file first!";
      return;
    }

    try {
      const contract = await loadContract();

      const fee = await contract.getFixedFee();

      // Send transaction: notarizeFile(bytes32 fileHash) payable
      const tx = await contract.notarizeFile("0x" + fileHashHex, { value: fee });
      status.innerText = "Transaction sent! Waiting for confirmation...";

      await tx.wait();  // Wait for the transaction to be confirmed
      status.innerText = "File notarized successfully! TxHash: " + tx.hash;

    } catch (error) {
      console.error(error);
      status.innerText = "Error while notarizing file: " + error.message;
    }
  });
});
