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
});
