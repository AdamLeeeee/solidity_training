const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WETH test", function () {

  beforeEach(async function () {
    const WETH = await ethers.getContractFactory("WETH");
    wrapETH = await WETH.deploy();
    await wrapETH.deployed();

    [user] = await ethers.getSigners();
  });

  it("should deposit successfully", async function () {
    const amount = ethers.utils.parseUnits("1", "ether");

    await wrapETH.connect(user).deposit({ value: amount });

    const balance = await wrapETH.balanceOf(user.address);
    expect(amount).to.equal(balance);
  });

  it("should withdraw successfully", async function () {
    const deposit_amount = ethers.utils.parseUnits("1", "ether");
    const withdraw_amount = ethers.utils.parseUnits("0.5", "ether");

    await wrapETH.connect(user).deposit({ value: deposit_amount });

    const userBalanceBefore = await ethers.provider.getBalance(user.address);

    await wrapETH.connect(user).withdraw(withdraw_amount);

    const wethBalance = await wrapETH.balanceOf(user.address);
    expect(wethBalance).to.equal(deposit_amount.sub(withdraw_amount));

    const userBalanceAfterWithdraw = await ethers.provider.getBalance(user.address);
    expect(userBalanceAfterWithdraw).to.be.closeTo(
      userBalanceBefore.add(withdraw_amount),
      ethers.utils.parseUnits("0.01", "ether")
    );
  });
});
