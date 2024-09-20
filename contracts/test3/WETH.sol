// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    constructor() ERC20 ("Wrapper Ether", "WETH"){}

    function deposit() public payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public {
        require(balanceOf(msg.sender) >= _amount, "no enough balance");
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount); 
    }

    receive() external payable {
        deposit();
    }
}