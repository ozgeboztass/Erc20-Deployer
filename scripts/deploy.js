// Deployment script for ERC20Factory
const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying ERC20Factory...");

  // Get the deployer's address
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Deploy the ERC20Factory
  const ERC20Factory = await ethers.getContractFactory("ERC20Factory");
  const factory = await ERC20Factory.deploy(deployer.address);
  
  await factory.waitForDeployment();
  
  const factoryAddress = await factory.getAddress();
  console.log("ERC20Factory deployed to:", factoryAddress);
  
  console.log("Deployment completed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 