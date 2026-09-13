// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC1155 is ERC1155, Ownable {
    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {}

    enum tokenType {
        Fungible,
        SemiFungible,
        NFT
    }

    struct TokenInfo {
        string name;
        tokenType TokenType;
    }

    mapping(uint256 => TokenInfo) public tokenInfo;

    uint256 public nextTokenId = 1;

    function createToken(
        string memory _tokenName,
        tokenType _tokenTypee
    ) public onlyOwner {
        tokenInfo[nextTokenId] = TokenInfo({
            name: _tokenName,
            TokenType: _tokenTypee
        });
        nextTokenId++;
    }

    function mint(
        address _adddress,
        uint256 tokenId,
        uint256 _amount
    ) public onlyOwner {
        require(
            tokenId > 0 && tokenId < nextTokenId,
            "Invalid Token Id Thanks!"
        );

        tokenType _type = tokenInfo[tokenId].TokenType;

        if (_type == tokenType.NFT) {
            require(_amount > 1, "NFT Amount Must be 1");
        }
        require(_amount > 0, "Amount must be greater than zero");

        _mint(_adddress, tokenId, _amount, "");
    }
}
