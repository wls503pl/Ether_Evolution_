// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// IERC721 Receiver Interface:
// The contract must implement this interface to receive ERC721 via secure transfer
interface IERC721Receiver
{
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns(bytes4);
}