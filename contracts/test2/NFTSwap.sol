// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTSwap {
    struct Order {
        uint price;
        address owner;
    }

    mapping(address => mapping(uint => Order)) public orders;

    function list(address nftContract, uint tokenId, uint price) external  {
        IERC721 nft = IERC721(nftContract);

        require(nft.ownerOf(tokenId) == msg.sender, "not owner");
        require(nft.getApproved(tokenId) == address(this), "not approved");
        require(orders[nftContract][tokenId].owner == address(0) , "already ordered");

        orders[nftContract][tokenId] = Order(price, msg.sender);
    }
    
    function revoke(address nftContract, uint tokenId) external {
        Order memory order = orders[nftContract][tokenId];

        require(order.owner == msg.sender, "not owner");

        delete orders[nftContract][tokenId];
    }

    function update(address nftContract, uint tokenId, uint newPrice) external  {
        Order memory order = orders[nftContract][tokenId];

        require(order.owner == msg.sender, "not owner");

        orders[nftContract][tokenId] = Order(newPrice, msg.sender);
    }

    function purchase(address nftContract, uint tokenId) external payable {
        Order memory order = orders[nftContract][tokenId];

        require(order.owner != address(0), "nft has not for sale");
        require(order.price == msg.value, "price is not equal");

        IERC721(nftContract).safeTransferFrom(order.owner, msg.sender, tokenId);

        payable(order.owner).transfer(msg.value);

        delete orders[nftContract][tokenId];

    }
}