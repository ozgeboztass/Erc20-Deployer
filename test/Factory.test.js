const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20Factory", function () {
  let factory;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const ERC20Factory = await ethers.getContractFactory("ERC20Factory");
    factory = await ERC20Factory.deploy(owner.address);
  });

  describe("Token Creation", function () {
    it("Should allow creating a new token", async function () {
      const tokenConfig = {
        maxTxAmount: ethers.parseEther("1000"),
        maxWalletBalance: ethers.parseEther("5000"),
        blacklistable: true,
        pausable: true,
        cooldownTime: 30
      };

      // Bekle ve dinle yaklaşımı ile event yakalama
      await expect(factory.createToken(
        "Test Token", 
        "TST", 
        ethers.parseEther("1000000"), 
        tokenConfig,
        { value: ethers.parseEther("0.015") }
      )).to.emit(factory, "TokenCreated");

      // Tüm tokenleri kontrol et
      const allTokens = await factory.getAllTokens();
      expect(allTokens.length).to.be.equal(1);

      // Oluşturan kullanıcının tokenlerini kontrol et
      const createdTokens = await factory.getTokensByCreator(owner.address);
      expect(createdTokens.length).to.be.equal(1);
    });

    it("Should reject creating a token with insufficient fee", async function () {
      const tokenConfig = {
        maxTxAmount: ethers.parseEther("1000"),
        maxWalletBalance: ethers.parseEther("5000"),
        blacklistable: true,
        pausable: true,
        cooldownTime: 30
      };

      await expect(factory.createToken(
        "Test Token", 
        "TST", 
        ethers.parseEther("1000000"), 
        tokenConfig,
        { value: ethers.parseEther("0.005") }
      )).to.be.revertedWith("Insufficient fee");
    });
  });
}); 