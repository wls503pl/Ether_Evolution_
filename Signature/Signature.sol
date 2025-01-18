// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC721/ERC721.sol";

// ECDSA Library
library ECDSA
{
    /**
     * Verify the signature address through ECDSA and return true if it is correct.
     * _msgHash is message's hash.
     * _signature is signature.
     * _signer is address of signature.
     **/
    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) internal pure returns (bool)
    {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    // @dev recover address of signer from _msgHash and signature _sgnature
    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address)
    {
        // check the length of signature, 65 is the length of the standard r, s, v signature.
        require(65 == _signature.length, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Currently, only assembly (inline assembly) can be used to obtain the values ​​of r, s, and v from the signature.
        assembly
        {
            /**
             * The first 32 bytes store the length of the signature (dynamic array storage rules)
             * add(sig, 32) = sig's pointer + 32
             * This is equivalent to skipping the first 32 bytes of the signature.
             * mload(p) loads the next 32 bytes of data starting from memory address p.
             **/

            // Read the 32 bytes data after length of signature
            r := mload(add(_signature, 0x20))

            // Read the next 32 bytes
            s := mload(add(_signature, 0x40))

            // Read the last byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // Use ecrecover (global function): use msgHash and r,s,v to recover the signer address
        return ecrecover(_msgHash, v, r, s);
    }
}
