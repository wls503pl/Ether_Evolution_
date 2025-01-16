// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/ERC721.sol";

/**
 * Use the Merkle tree to verify the whitelist (webpage for generating the Merkle tree:
 * https://lab.miguelmota.com/merkletreejs/example/)
 * Select "Keccak-256", "hashLeaves" and "sortPairs" options
 * 4 leaf addresses:
    [
        "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 
        "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
        "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
        "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"
    ]
 * The 1st address's corresponding Merkle proof:
    [
        "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",
        "0x4726e4102af77216b09ccd94f40daa10531c87c4d60bba7f3b3faf5ff9f19b3c"
    ]
 * Merkle root: 0xeeefd63003e0e702cb41cd0043015a6e26ddb38073cc6ffeb0ba3e808ba8c097
 **/

/*
 * @dev, Verify the Merkle tree's contract
 * The proof can be generated using the JavaScript library:
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * 
 * note, hash uses "keccak256" and "Pair Sorting" is enabled.
 * For javascript examples, see 
 * 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/utils/cryptography/MerkleProof.test.js'
 */
library MerkleProof
{
    /**
     * @dev When the 'root' reconstructed by 'proof' and 'leaf' is equal to the given 'root',
     *      'true' is returned and the data is valid.
     *      During reconstruction, leaf node pairs and element pairs are sorted.
     **/
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf) internal pure returns(bool)
    {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns Calculate 'root' using 'leaf' and 'proof' through the Merkle tree.
     *      'proof' is valid only when the reconstructed 'root' is the same as the given 'root'.
     *      During reconstruction, both leaf node pairs and element pairs are sorted.
     **/
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32)
    {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++)
        {
            computedHash = _hashPair(computedHash, proof[i]);
        }

        return computedHash;
    }

    // Sorted Pair Hash
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32)
    {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

contract MerkleTree is ERC721
{
    // root of Merkle tree
    bytes32 immutable public root;

    // Record the minted address
    mapping(address => bool) public mintedAddress;

    // Use the Merkle book to verify the address and mint
    function mint(address account, uint256 tokenId, bytes32[] calldata proof) external
    {
        // Merkle check passed
        require(_verify(_leaf(account), proof), "Invalid merkle proof");
        
        // The address has not been minted
        require(!mintedAddress[account], "Already minted!");
        
        // Record the minted address
        mintedAddress[account] = true;

        // mint
        _mint(account, tokenId);
    }

    // Calculate the hash value of the Merkle book leaf
    function _leaf(address account) internal pure returns(bytes32)
    {
        return keccak256(abi.encodePacked(account));
    }

    // Merkle tree verification, calling the verify() function of the MerkleProof library
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }
}

    
