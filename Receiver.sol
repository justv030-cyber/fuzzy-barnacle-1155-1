    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.34;

    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155Receiver.sol";
    // import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
    // import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol";

    contract Receiver is IERC1155Receiver ,ERC165 {
        function onERC1155Received(
            address operator,
            address from,
            uint256 id,
            uint256 value,
            bytes calldata data
        ) external returns (bytes4) {
            return this.onERC1155Received.selector;
        }

        function onERC1155BatchReceived(
            address operator,
            address from,
            uint256[] calldata ids,
            uint256[] calldata values,
            bytes calldata data
        ) external returns (bytes4) {
            return this.onERC1155BatchReceived.selector;
        }

        function supportsInterface(
            bytes4 interfaceId
        ) public view virtual override(ERC165, IERC165) returns (bool) {
            return
                interfaceId == type(IERC1155Receiver).interfaceId ||
                super.supportsInterface(interfaceId);
        }
    }
