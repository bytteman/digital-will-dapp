const hre = require("hardhat");

async function main() {
  // These are example addresses. You'd get them from your frontend.
  const executorAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"; // Example: Hardhat's second account
  const initialWillCID = "Qm...some...hash"; // Example IPFS hash
  const initialDeposit = hre.ethers.utils.parseEther("1.0"); // Deploy with 1 ETH

  const DigitalWill = await hre.ethers.getContractFactory("DigitalWill");
  const digitalWill = await DigitalWill.deploy(executorAddress, initialWillCID, { value: initialDeposit });

  await digitalWill.deployed();

  console.log(`DigitalWill contract deployed to: ${digitalWill.address}`);
  console.log(`Initial deposit of ${hre.ethers.utils.formatEther(initialDeposit)} ETH`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});