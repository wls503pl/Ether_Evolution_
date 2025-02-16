// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title ERC165 standard interface, see:
 * https://eips.ethereum.org/EIPS/eip-165[EIP]
 *
 **/
interface IERC165 {
    /**
     * @dev Returns true if the contract implements the queried 'interfaceId'
     * For details of the rules, please refer to:
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     *
     */
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}