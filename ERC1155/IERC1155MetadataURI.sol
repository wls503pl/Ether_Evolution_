// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC1155.sol";

/**
 * @dev ERC1155 optional interface, added uri() function to query metadata
 */
interface IERC1155MetadataURI is IERC1155
{
    /**
     * @dev Returns the URI of the token of type `id`
     */
    function uri(uint256 id) external view returns (string memory);
}
