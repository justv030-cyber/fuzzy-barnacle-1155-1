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

    constructor(address intialOwner) {
        NFT = IERC1155(intialOwner);
    }

    function listItem(
        uint256 _tokenId,
        uint256 _amt,
        uint256 _pricePerItem
    ) public {
        require(
            NFT.balanceOf(msg.sender, _tokenId) >= _amt,
            "Not enough to list"
        );
        require(
            NFT.isApprovedForAll(msg.sender, address(this)),
            "NFT Is No Approve"
        );
        listingId++;

        listings[listingId] = Listing({
            sellerAddress: msg.sender,
            tokenId: _tokenId,
            amount: _amt,
            pricePerItem: _pricePerItem,
            active: true
        });
    }

    function butItem(uint256 _listingId) public payable {
        require(listings[_listingId].active == true, "Listing Is Not Active");

        uint256 price = listings[_listingId].pricePerItem *
            listings[_listingId].amount;
        require(msg.value >= price, "Insufficient Funds");

        NFT.safeTransferFrom(
            listings[_listingId].sellerAddress,
            msg.sender,
            listings[_listingId].tokenId,
            listings[_listingId].amount,
            ""
        );

        listings[_listingId].active = false;
    }
}
