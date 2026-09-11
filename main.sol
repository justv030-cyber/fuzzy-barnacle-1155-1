// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.38;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/payment/PaymentSplitter.sol";

contract Zuruki is
    ERC1155,
    Ownable,
    ERC1155Pausable,
    ERC1155Supply,
    PaymentSplitter
{
    uint256 public publicMintPrice = 0.002 ether;

    uint256 public whiteListMint = 0.001 ether;

    uint256 public maxPerWallet = 10;

    uint256 public maxSupply = 400;

    address public ownerContract;

    bool public allowListMintOpen = true;

    bool public PublicMintOpen = false;

    mapping(address => bool) public allowList;

    mapping(address => uint256) public purchasesPerWallet;

    constructor(
        address initialOwner,
        address[] memory _payees,
        uint256[] memory _shares
    )
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
        Ownable(initialOwner)
        PaymentSplitter(_payees, _shares)
    {
        ownerContract = initialOwner;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setallowList(bool _allowListMintOpen) public onlyOwner {
        allowListMintOpen = _allowListMintOpen;
    }

    function setPublicMintAllow(bool _PublicMintOpen) public onlyOwner {
        PublicMintOpen = _PublicMintOpen;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function publicMint(uint256 id, uint256 amount) public payable {
        require(PublicMintOpen, "Public Mint Is Closed");
        require(
            purchasesPerWallet[msg.sender] + amount <= maxPerWallet,
            "Wallet Limit Is Reached"
        );
        require(
            msg.value == publicMintPrice * amount,
            "Not Enough Money For Mint!"
        );
        require(totalSupply(id) + amount < maxSupply, "Sorry We Are Mint Out!");
        _mint(msg.sender, id, amount, "");
        purchasesPerWallet[msg.sender] += amount;
    }

    function setAllowList(address[] memory _add) external onlyOwner {
        for (uint256 i = 0; i <= _add.length; i++) {
            allowList[_add[i]] = true;
        }
    }

    function allowListMint(uint256 _id, uint256 _amt) public payable onlyOwner {
        require(allowListMintOpen, "Allow List Mint Is Closed");
        require(allowList[msg.sender], "You Are Not On The Allow List Thanks!");
        require(msg.value == whiteListMint * _amt, "Insufficient Balance");
        require(totalSupply(_id) + _amt < maxSupply, "Sorry We Are Mint Out!");
        _mint(msg.sender, _id, _amt, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    function uri(
        uint256 _id
    ) public view virtual override returns (string memory) {
        require(exists(_id), "URI: This ID Does Not Exist");

        return
            string(
                abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json")
            );
    }

    function withdraw() external onlyOwner {
        require(
            msg.sender == ownerContract,
            "You Are Not Owner Of this Contract"
        );
        uint256 getBalance = address(this).balance;
        (bool sucess, ) = payable(msg.sender).call{value: getBalance}("");
        require(sucess, "Transfer Failed");
    }
}
