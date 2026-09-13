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
}
