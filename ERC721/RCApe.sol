// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC721.sol";

contract RCApe is ERC721{
    // Total amount of RC APEs
    uint public MAX_APES = 10000;

    // constructor function
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_)
    {}

    // The baseURI of BAYC is ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/
    function _baseURI() internal pure override returns(string memory)
    {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }
    
    // Minting function
    function mint(address to, uint tokenId) external
    {
        require(tokenId >= 0 && tokenId < MAX_APES, "tokenId out of range");
        _mint(to, tokenId);
    }
}