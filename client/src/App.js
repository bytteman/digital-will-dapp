import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
// Import the contract ABI
import DigitalWillArtifact from './artifacts/contracts/DigitalWill.sol/DigitalWill.json';

// **PASTE YOUR DEPLOYED CONTRACT ADDRESS HERE**
const contractAddress = "YOUR_CONTRACT_ADDRESS_HERE";

function App() {
  // No changes needed to the state variables
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState(null);

  // This is the main function to update for Ethers v6
  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        // 1. Create a new provider using the v6 syntax
        const provider = new ethers.BrowserProvider(window.ethereum);
        
        // 2. Get the signer (the user's account)
        const signer = await provider.getSigner();
        
        // 3. Get the account address
        const userAccount = await signer.getAddress();
        setAccount(userAccount);

        // 4. Create the contract instance
        const contractInstance = new ethers.Contract(contractAddress, DigitalWillArtifact.abi, signer);
        setContract(contractInstance);

        console.log("Wallet connected successfully!");

      } catch (error) {
        console.error("Error connecting wallet:", error);
      }
    } else {
      console.error("Please install MetaMask!");
      alert("MetaMask is not installed. Please install it to use this DApp.");
    }
  };
  
  // --- This function to interact with the contract remains the same ---
  const handleDeclareDeceased = async () => {
    if (!contract) {
        alert("Please connect your wallet first.");
        return;
    }
    try {
        console.log("Attempting to declare deceased...");
        const tx = await contract.declareDeceased();
        await tx.wait(); // Wait for the transaction to be mined
        alert("Success! The owner has been declared deceased.");
    } catch (error) {
        console.error("Error declaring deceased:", error);
        // The error object in ethers v6 is more detailed
        alert("Error: " + (error.reason || error.message));
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Digital Will DApp</h1>
        {account ? (
          <div>
            <p>Connected Account: {account}</p>
            {/* Add more UI buttons and inputs here as you build */}
            <button onClick={handleDeclareDeceased}>Declare Deceased (Executor Only)</button>
          </div>
        ) : (
          <button onClick={connectWallet}>Connect Wallet</button>
        )}
      </header>
    </div>
  );
}

export default App;