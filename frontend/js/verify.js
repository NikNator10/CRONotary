document.addEventListener("DOMContentLoaded", () => {
  const fileInput = document.getElementById("fileInput");
  const addressInput = document.getElementById("addressInput");
  const verifyBtn = document.getElementById("verifyBtn");
  const status = document.getElementById("status");

  let fileHashHex = null;

  fileInput.addEventListener("change", async (event) => {
    const file = event.target.files[0];
    if (file) {
      fileHashHex = await sha256FromFile(file);
      status.style.color = "blue"; 
      status.innerText = `SHA-256 Hash: ${fileHashHex}`;
    }
  });

  verifyBtn.addEventListener("click", async () => {
    const address = addressInput.value.trim();

    if (!fileHashHex) {
      status.style.color = "red";
      status.innerText = "Please select a file first.";
      return;
    }

    if (!address) {
      status.style.color = "red";
      status.innerText = "Please enter a valid address.";
      return;
    }

    try {
      const contract = await loadContract();
      const isSigned = await contract.isFileSignedbyUser("0x" + fileHashHex, address);

      if (isSigned) {
        status.style.color = "green";
        status.innerText = `${address} HAS signed this document.`;
      } else {
        status.style.color = "red";
        status.innerText = `${address} has NOT signed this document.`;
      }
    } catch (error) {
      console.error(error);
      status.style.color = "red";
      status.innerText = "Error during verification: " + error.message;
    }
  });
});
