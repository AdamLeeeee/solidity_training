// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "contracts/test3/WETH.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract WETH_LP {
    address public weth;
    address public token;
    // permill， eg. serviceChange = 3 => 0.3%  
    uint16 public serviceChange;

    uint public totalLiquidity;
    mapping(address => uint) public liquidity;

    constructor(address _weth, address _token, uint16 _serviceChange) {
        weth = _weth;
        token = _token;
        serviceChange = _serviceChange;
    }

    //add liquidity
    function addLiquidity(uint _wethAmount, uint _tokenAmount) external payable {
        uint wethBalance = IWETH(weth).balanceOf(address(this));
        uint tokenBalance = IERC20(token).balanceOf(address(this));
        uint minTokenAmount = ((_wethAmount + wethBalance) * tokenBalance / wethBalance ) - tokenBalance;
        require(_wethAmount > 0 && _tokenAmount >= minTokenAmount, "Invalid amounts");

        IWETH(weth).transferFrom(msg.sender, address(this), _wethAmount);
        IERC20(token).transferFrom(msg.sender, address(this), _tokenAmount);

        uint lpMinted = _wethAmount; // simple LP rule
        liquidity[msg.sender] += lpMinted;
        totalLiquidity += lpMinted;
    }

    function removeLiquidity(uint _amount) external {
        require(liquidity[msg.sender] >= _amount, "user has not enough lp");

        uint wethAmount = _amount * IWETH(weth).balanceOf(address(this)) / totalLiquidity;
        uint tokenAmount = _amount * IERC20(token).balanceOf(address(this)) / totalLiquidity;
        liquidity[msg.sender] -= _amount;
        totalLiquidity -= _amount;

        IWETH(weth).transfer(msg.sender, wethAmount);
        IERC20(token).transfer(msg.sender, tokenAmount);
    }

    function swapWETHForToken(uint _wethAmount) external {
        require(_wethAmount > 0, "Invalid amounts");
        
        uint wethReserve = IWETH(weth).balanceOf(address(this));
        uint tokenReserve = IERC20(token).balanceOf(address(this));
        
        uint tokenAmount = getAmountOut(_wethAmount, wethReserve, tokenReserve);

        IWETH(weth).transferFrom(msg.sender, address(this), _wethAmount);
        IERC20(token).transfer(msg.sender, tokenAmount);
    }

    function swapTokenForWETH(uint _tokenAmount) external {
        require(_tokenAmount > 0, "Invalid amounts");
        
        uint wethReserve = IWETH(weth).balanceOf(address(this));
        uint tokenReserve = IERC20(token).balanceOf(address(this));
        
        uint wethAmount = getAmountOut(_tokenAmount, tokenReserve, wethReserve);

        IERC20(token).transferFrom(msg.sender, address(this), _tokenAmount);
        IWETH(weth).transfer(msg.sender, wethAmount);
    }

    function getAmountOut(uint _inputAmount,uint _inputReserve,uint _outputReserve) internal view returns (uint){
        require(_inputReserve > 0 && _outputReserve > 0, "Invalid reserves");

        uint actualInput = _inputAmount * (1000 - serviceChange);

        return (actualInput * _outputReserve) / (_inputReserve * 1000 + actualInput);
    }
}