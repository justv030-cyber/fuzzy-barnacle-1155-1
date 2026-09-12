// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/IERC2981.sol";

contract marketPlace is ReentrancyGuard, Ownable {
    uint256 public listingId;
    IERC1155 public NFT;
    IERC2981 public royaltyNFT;

    uint256 public marketplaceFee = 250; //2.5%

    struct Listing {
        address sellerAddress;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerItem;
        bool active;
    }

    mapping(uint256 => Listing) public listings;

    constructor(address intialOwner, address _NFTAddress) Ownable(intialOwner) {
        NFT = IERC1155(_NFTAddress);
        royaltyNFT = IERC2981(_NFTAddress);
    }

    // event item listed

    event ItemListed(
        uint256 listingId,
        address seller,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerItem
    );

    //custom error

    error NotEnoughToList();
    error NotApprove();

    function listItem(
        uint256 _tokenId,
        uint256 _amt,
        uint256 _pricePerItem
    ) public {
        if (NFT.balanceOf(msg.sender, _tokenId) <= _amt) {
            revert NotEnoughToList();
        }
        if (NFT.isApprovedForAll(msg.sender,address(this))) {
            revert NotApprove();
        }
        listingId++;

        listings[listingId] = Listing({
            sellerAddress: msg.sender,
            tokenId: _tokenId,
            amount: _amt,
            pricePerItem: _pricePerItem,
            active: true
        });

        emit ItemListed(_tokenId, msg.sender, _tokenId, _amt, _pricePerItem);
    }

    function buyItem(
        uint256 _listingId,
        uint256 _amount
    ) public payable nonReentrant {
        require(listings[_listingId].active == true, "Listing Is Not Active");
        require(_amount > 0, "Invalid Amount Try Again Later!");
        require(
            _amount <= listings[_listingId].amount,
            "Invalid Amount Please Try Again Later!"
        );

        uint256 price = listings[_listingId].pricePerItem * _amount;
        require(msg.value == price, "Insufficient Funds");

        (address _royaltyreceiver, uint256 _RoyaltyAmount) = royaltyNFT
            .royaltyInfo(listings[_listingId].tokenId, price);

        uint256 RemainingBalance = listings[_listingId].amount - _amount;

        listings[_listingId].amount = RemainingBalance;

        NFT.safeTransferFrom(
            listings[_listingId].sellerAddress,
            msg.sender,
            listings[_listingId].tokenId,
            _amount,
            ""
        );

        if (listings[_listingId].amount == 0) {
            listings[_listingId].active = false;
        } else {
            listings[_listingId].active = true;
        }

        uint256 fees = (price * marketplaceFee) / 10000;

        require(_RoyaltyAmount + fees <= price, "Fees exceed sale price");

        uint256 sellerAmount = price - _RoyaltyAmount - fees;

        if (_RoyaltyAmount > 0) {
            (bool sucess, ) = payable(_royaltyreceiver).call{
                value: _RoyaltyAmount
            }("");
            require(sucess, "Transfe Failed");
        }

        (bool sucess, ) = payable(listings[_listingId].sellerAddress).call{
            value: sellerAmount
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

    function buyMultipleItems(
        uint256[] calldata _listingIds,
        uint256[] calldata _amounts
    ) public payable nonReentrant {
        uint256 totalPrice = 0;
        require(_listingIds.length == _amounts.length, "Invalid Length");

        for (uint256 i = 0; i < _listingIds.length; i++) {
            require(listings[_listingIds[i]].active, "Lisitng Is Not Active");
            require(listings[_listingIds[i]].amount > 0, "Invalid Amounts");
            require(
                _amounts[i] <= listings[_listingIds[i]].amount,
                "Invali Amounts Thanks!"
            );

            totalPrice += listings[_listingIds[i]].pricePerItem * _amounts[i];

            uint256 remainingBalance = listings[_listingIds[i]].amount -
                _amounts[i];

            listings[_listingIds[i]].amount = remainingBalance;

            if (remainingBalance == 0) {
                listings[_listingIds[i]].active = false;
            } else {
                listings[_listingIds[i]].active = true;
            }

            NFT.safeTransferFrom(
                listings[_listingIds[i]].sellerAddress,
                msg.sender,
                listings[_listingIds[i]].tokenId,
                _amounts[i],
                ""
            );

            uint256 salePrice = listings[_listingIds[i]].pricePerItem *
                _amounts[i];

            (address royalyAddress, uint256 royaltyAmmount) = royaltyNFT
                .royaltyInfo(listings[_listingIds[i]].tokenId, salePrice);

            uint256 Fees = (salePrice * marketplaceFee) / 10000;

            require(
                royaltyAmmount + Fees <= salePrice,
                "Fees exceed sale price"
            );

            uint256 sellerAmount = salePrice - royaltyAmmount - Fees;

            if (royaltyAmmount > 0) {
                (bool sucess, ) = payable(royalyAddress).call{
                    value: royaltyAmmount
                }("");
                require(sucess, "Transfer Failes");
            }

            (bool sucess, ) = payable(listings[_listingIds[i]].sellerAddress)
                .call{value: sellerAmount}("");
            require(sucess, "Trannsfer Failed Please Try Again Later!");
        }
        require(msg.value == totalPrice, "Insufficient Balance");
    }
}
