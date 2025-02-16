// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/IERC165.sol";

/**
 * @dev ERC1155 standard interface contract, implementing the functions of EIP1155
 * For details, see: https://eips.ethereum.org/EIPS/eip-1155[EIP].
 */
interface IERC1155 is IERC165
{
    /**
     * @dev Single-type token transfer event
     * Released when the tokens of type `value` and `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Multiple token transfer events
     * ids and values ​​are arrays of token types and quantities to be transferred
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values);
    
    /**
     * @dev Batch authorization event
     * Released when `account` authorizes all tokens to `operator`
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Released when the URI of the token of type `id` changes, `value` is the new URI
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Position query, returns the holding amount of tokens of type `id` owned by `account`
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev Batch position query, the lengths of `accounts` and `ids` arrays must be equal.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    
    /**
     * @dev batch authorization, authorize the caller's token to the `operator` address.
     * Release {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Batch authorization query, if the authorized address `operator` is authorized by `account`, return `true`
     * See {setApprovalForAll} function.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Secure transfer, transfer the token of `amount` unit `id` type from `from` to `to`.
     * Release {TransferSingle} event.
     * Requirements:
     * - If the caller is not the `from` address but an authorized address, it is necessary to obtain authorization from `from`
     * - The `from` address must have sufficient positions
     * - If the receiver is a contract, it is necessary to implement the `onERC1155Received` method of `IERC1155Receiver` and return the corresponding value
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Batch secure transfer
     * Release {TransferBatch} event
     * Requirements:
     * - `ids` and `amounts` are of equal length
     * - If the receiver is a contract, the `onERC1155BatchReceived` method of `IERC1155Receiver` needs to be implemented and the corresponding value returned
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
