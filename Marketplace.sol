// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

 import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol";


contract marketPlace {

    uint256 public listingId;
    IERC1155 public NFT;

    struct Listing {
        address sellerAddress;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerItem;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    constructor(address intialOwner){
        NFT = IERC1155(intialOwner);
    }
}
