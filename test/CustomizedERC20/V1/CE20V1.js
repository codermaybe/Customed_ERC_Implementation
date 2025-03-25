const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("CE20V1", function () {
  let CE20V1;
  let ce20v1;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // 获取合约工厂
    CE20V1 = await ethers.getContractFactory("CE20V1");
    // 部署合约
    [owner, addr1, addr2] = await ethers.getSigners();
    ce20v1 = await CE20V1.deploy(
      "CE20V1",
      "CE20V1",
      18,
      ethers.parseEther("1000")
    );
    await ce20v1.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await ce20v1.balanceOf(owner.address)).to.equal(
        ethers.parseEther("1000")
      );
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await ce20v1.balanceOf(owner.address);
      expect(await ce20v1.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      // Transfer 50 tokens from owner to addr1
      await ce20v1.transfer(addr1.address, ethers.parseEther("50"));
      const addr1Balance = await ce20v1.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(ethers.parseEther("50"));

      // Transfer 50 tokens from addr1 to addr2
      await ce20v1
        .connect(addr1)
        .transfer(addr2.address, ethers.parseEther("50"));
      const addr2Balance = await ce20v1.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(ethers.parseEther("50"));
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const initialOwnerBalance = await ce20v1.balanceOf(owner.address);

      // Try to send 1 token from addr1 (0 tokens) to owner (1000 tokens)
      await expect(
        ce20v1.connect(addr1).transfer(owner.address, ethers.parseEther("1"))
      ).to.be.revertedWith("余额不足");

      // Owner balance shouldn't have changed
      expect(await ce20v1.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });

    it("Should update allowances after approval", async function () {
      await ce20v1.approve(addr1.address, ethers.parseEther("100"));
      expect(await ce20v1.allowance(owner.address, addr1.address)).to.equal(
        ethers.parseEther("100")
      );
    });

    it("Should transfer tokens using transferFrom", async function () {
      await ce20v1.approve(addr1.address, ethers.parseEther("100"));
      await ce20v1
        .connect(addr1)
        .transferFrom(owner.address, addr2.address, ethers.parseEther("50"));
      expect(await ce20v1.balanceOf(addr2.address)).to.equal(
        ethers.parseEther("50")
      );
    });

    it("Should fail if transferFrom exceeds allowance", async function () {
      await ce20v1.approve(addr1.address, ethers.parseEther("50"));
      await expect(
        ce20v1
          .connect(addr1)
          .transferFrom(owner.address, addr2.address, ethers.parseEther("100"))
      ).to.be.revertedWith(`授权额度不足`);
    });
  });

  describe("Minting", function () {
    it("Should mint tokens to the specified address", async function () {
      await ce20v1.mint(addr1.address, ethers.parseEther("100"));
      expect(await ce20v1.balanceOf(addr1.address)).to.equal(
        ethers.parseEther("100")
      );
      expect(await ce20v1.totalSupply()).to.equal(ethers.parseEther("1100"));
    });

    it("Should fail if non-owner tries to mint", async function () {
      await expect(
        ce20v1.connect(addr1).mint(addr1.address, ethers.parseEther("100"))
      ).to.be.revertedWith(`非合约拥有者无法派生代币`);
    });
  });

  describe("Burning", function () {
    it("Should burn tokens from the specified address", async function () {
      await ce20v1.burn(owner.address, ethers.parseEther("100"));
      expect(await ce20v1.balanceOf(owner.address)).to.equal(
        ethers.parseEther("900")
      );
      expect(await ce20v1.totalSupply()).to.equal(ethers.parseEther("900"));
    });

    it("Should fail if non-owner tries to burn", async function () {
      await expect(
        ce20v1.connect(addr1).burn(owner.address, ethers.parseEther("100"))
      ).to.be.revertedWith(`非合约拥有者无法派生代币`);
    });
  });
});
