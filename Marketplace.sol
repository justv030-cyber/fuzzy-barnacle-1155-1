// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol";
import "http://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract marketPlace is ReentrancyGuard, Ownable {
    uint256 public listingId;
    IERC1155 public NFT;

    uint256 marketplaceFee = 250; //2.5%

    struct Listing {
        address sellerAddress;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerItem;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    constructor(address intialOwner) Ownable(intialOwner) {
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

    function buyItem(uint256 _listingId) public payable nonReentrant {
        require(listings[_listingId].active == true, "Listing Is Not Active");

        uint256 price = listings[_listingId].pricePerItem *
            listings[_listingId].amount;
        require(msg.value == price, "Insufficient Funds");

        listings[_listingId].active = false;

        NFT.safeTransferFrom(
            listings[_listingId].sellerAddress,
            msg.sender,
            listings[_listingId].tokenId,
            listings[_listingId].amount,
            ""
        );

        uint256 Fees = (msg.value * marketplaceFee) / 10000;

        uint256 sendPrice = msg.value - Fees;

        (bool sucess, ) = payable(listings[_listingId].sellerAddress).call{
            value: sendPrice
        }("");
        require(sucess, "Transfer Failed");
    }

    function cancelListing(uint256 _listingId) public {
        require(listings[_listingId].active == true, "NFT Is Not Listed");
        require(
            msg.sender == listings[_listingId].sellerAddress,
            "You Are Not Seller"
        );
        listings[_listingId].active = false;
    }

    function updatePrice(uint256 _listingId, uint256 _updatePrice) public {
        require(listings[_listingId].active == true, "Lisiting Is Not Active");
        require(
            msg.sender == listings[_listingId].sellerAddress,
            "You Are Not Seller"
        );

        listings[_listingId].pricePerItem = _updatePrice;
    }

    function withdrawFees() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees available");

        (bool sucess, ) = payable(msg.sender).call{value: balance}("");
        require(sucess, "Transfer Failedx");
    }
}
