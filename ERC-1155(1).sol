// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC1155 is ERC1155Supply, Ownable {
    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {}

    enum TokenType {
        Fungible,
        SemiFungible,
        NFT
    }

    struct TokenInfo {
        string name;
        TokenType tokenType;
        uint256 maxSupply;
    }

    mapping(uint256 => TokenInfo) public tokenInfo;

    uint256 public nextTokenId = 1;

    function createToken(
        string memory _tokenName,
        TokenType _tokenType,
        uint256 _maxSupply
    ) public onlyOwner {
        tokenInfo[nextTokenId] = TokenInfo({
            name: _tokenName,
            tokenType: _tokenType,
            maxSupply: _maxSupply
        });

        nextTokenId++;
    }

    function mint(
        address _address,
        uint256 tokenId,
        uint256 _amount
    ) public onlyOwner {
        require(tokenId > 0 && tokenId < nextTokenId, "Invalid Token Id");

        require(_amount > 0, "Amount must be greater than zero");

        TokenType _type = tokenInfo[tokenId].tokenType;

        if (_type == TokenType.NFT) {
            require(_amount == 1, "NFT amount must be 1");
        }

        require(
            totalSupply(tokenId) + _amount <= tokenInfo[tokenId].maxSupply,
            "Max supply exceeded"
        );

        _mint(_address, tokenId, _amount, "");
    }

    function mintBatch(
        address _address,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) public onlyOwner {
        require(tokenIds.length == amounts.length, "Invalid Length Thanks!");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                tokenIds[i] > 0 && tokenIds[i] < nextTokenId,
                "Invalid Token ID"
            );
            require(amounts[i] > 0, "Amount must be greater than zero");

            TokenType _type = tokenInfo[tokenIds[i]].tokenType;

            if (_type == TokenType.NFT) {
                require(amounts[i] == 1, "NFT amount must be 1");
            }

            require(
                totalSupply(tokenIds[i]) + amounts[i] <=
                    tokenInfo[tokenIds[i]].maxSupply,
                "Max supply exceeded"
            );

           
        }
        _mintBatch(_address, tokenIds, amounts, "");
    }

    
}
