// Sepolia ağı için deployment script
const { ethers, network } = require("hardhat");

async function main() {
  // Ağ bilgisini kontrol et
  console.log(`Deploying to ${network.name} network...`);
  
  // Deployer adresini al
  const [deployer] = await ethers.getSigners();
  
  console.log(`Deployer adresi: ${deployer.address}`);
  console.log(`Bakiye: ${ethers.formatEther(await deployer.provider.getBalance(deployer.address))} ETH`);

  // ERC20Factory kontratını deploy et
  console.log("ERC20Factory kontratı deploy ediliyor...");
  const ERC20Factory = await ethers.getContractFactory("ERC20Factory");
  const factory = await ERC20Factory.deploy(deployer.address);
  
  await factory.waitForDeployment();
  
  const factoryAddress = await factory.getAddress();
  console.log(`ERC20Factory kontratı başarıyla deploy edildi: ${factoryAddress}`);
  
  console.log("Verify komutu:");
  console.log(`npx hardhat verify --network sepolia ${factoryAddress} ${deployer.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 