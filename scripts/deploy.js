const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying GovernanceToken...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy("GovernanceToken", "GT");
  await governanceToken.deployed();
  console.log("GovernanceToken deployed to:", governanceToken.address);

  console.log("Deploying GovernorContract...");

  const GovernorContract = await ethers.getContractFactory("GovernorContract");
  const governorContract = await GovernorContract.deploy(governanceToken.address);
  await governorContract.deployed();
  console.log("GovernorContract deployed to:", governorContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });