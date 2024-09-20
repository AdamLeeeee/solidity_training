const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTSwap with IERC721", function () {
  let nftContract, swapContract, seller, buyer;

  beforeEach(async function () {
    const TestNFT = await ethers.getContractFactory("TestNFT");
    nftContract = await TestNFT.deploy();

    const NFTSwap = await ethers.getContractFactory("NFTSwap");
    swapContract = await NFTSwap.deploy();

    [owner, seller, buyer] = await ethers.getSigners();

    await nftContract.connect(seller).mint(seller.address);
  });

  it("seller order NFT successfully", async function () {
    const tokenId = 0;
    const price = ethers.utils.parseEther("1");

    await nftContract.connect(seller).approve(swapContract.address, tokenId);
    await swapContract.connect(seller).list(nftContract.address, tokenId, price);

    const order = await swapContract.orders(nftContract.address, tokenId);
    expect(order.owner).to.equal(seller.address);
    expect(order.price).to.equal(price);
  });

  it("seller order NFT failed by not owner", async function () {
    const tokenId = 0;
    const price = ethers.utils.parseEther("1");

    await nftContract.connect(seller).approve(swapContract.address, tokenId);
    await expect(
      swapContract.connect(buyer).list(nftContract.address, tokenId, price)
    ).to.be.revertedWith("not owner");
  });

  it("seller order NFT failed by not approved", async function () {
    const tokenId = 0;
    const price = ethers.utils.parseEther("1");

    await expect(
      swapContract.connect(seller).list(nftContract.address, tokenId, price)
    ).to.be.revertedWith("not approved");
  });

  it("seller order NFT failed by repeat order", async function () {
    const tokenId = 0;
    const price = ethers.utils.parseEther("1");

    await nftContract.connect(seller).approve(swapContract.address, tokenId);
    await swapContract.connect(seller).list(nftContract.address, tokenId, price);

    await expect(
      swapContract.connect(seller).list(nftContract.address, tokenId, price)
    ).to.be.revertedWith("already ordered");
  });

  it("卖家可以撤销挂单", async function () {
    const tokenId = 0;
    const price = ethers.utils.parseEther("1");

    await nftContract.connect(seller).approve(swapContract.address, tokenId);
    await swapContract.connect(seller).list(nftContract.address, tokenId, price);
    await swapContract.connect(seller).revoke(nftContract.address, tokenId);

    const order = await swapContract.orders(nftContract.address, tokenId);
    expect(order.owner).to.equal(ethers.constants.AddressZero);
    expect(await nftContract.ownerOf(tokenId)).to.equal(seller.address);
  });

  it("卖家可以更新挂单价格", async function () {
    const tokenId = 0;
    const initialPrice = ethers.utils.parseEther("1");
    const updatedPrice = ethers.utils.parseEther("2");

    await nftContract.connect(seller).approve(swapContract.address, tokenId);
    await swapContract.connect(seller).list(nftContract.address, tokenId, initialPrice);
    await swapContract.connect(seller).update(nftContract.address, tokenId, updatedPrice);

    const order = await swapContract.orders(nftContract.address, tokenId);
    expect(order.owner).to.equal(seller.address);
    expect(order.price).to.equal(updatedPrice);
  });

  it("买家可以成功购买 NFT", async function () {
    const tokenId = 0;
    const price = ethers.utils.parseEther("1");

    await nftContract.connect(seller).approve(swapContract.address, tokenId);
    await swapContract.connect(seller).list(nftContract.address, tokenId, price);
    await swapContract.connect(buyer).purchase(nftContract.address, tokenId, { value: price });
    const order = await swapContract.orders(nftContract.address, tokenId);

    expect(order.owner).to.equal(ethers.constants.AddressZero);
    expect(await nftContract.ownerOf(tokenId)).to.equal(buyer.address);
  });
});
