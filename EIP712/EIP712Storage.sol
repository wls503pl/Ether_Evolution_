// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EIP712Storage
{
    using ECDSA for bytes32;

    bytes32 private constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name, string version, uint256 chainId, address verifyingContract)");
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender, uint256 number)");
    bytes32 private DOMAIN_SEPARATOR;
    uint256 number;
    address owner;

    constructor()
    {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,              // type hash
            keccak256(bytes("EIP712Storage")),  // name
            keccak256(bytes("1")),              // version
            block.chainid,                      // chain id
            address(this)                       // contract address
        ));
        owner = msg.sender;
    }

    
    // @dev Store value in variable
    function permitStore(uint256 _num, bytes memory _signature) public
    {
        // Check the signature length. 65 is the length of the standard r, s, v signature.
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Currently only assembly (inline assembly)
        // can be used to obtain the values ​​of r, s, and v from the signature
        assembly
        {
            /*
             * The first 32 bytes store the length of the signature (dynamic array storage rules)
             * add(sig, 32) = sig's pointer + 32
             * this is equivalent to skipping the first 32 bytes of the signature.
             * mload(p) loads the next 32 bytes of data starting from memory address p
             */
             // Read the 32 bytes after the length data
             r := mload(add(_signature, 0x20))

             // Read the next 32 bytes
             s := mload(add(_signature, 0x40))

             // Read the last byte
             v := byte(0, mload(add(_signature, 0x60)))
        }

        // Get the signature message hash
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(STORAGE_TYPEHASH, msg.sender, _num))
        ));

        address signer = digest.recover(v, r, s);                       // Recover the signer
        require(signer == owner, "EIP712Storage: Invalid signature");   // Check signature

        // modify status variables
        number = _num;
    }

    /*
     * @dev Return value
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256)
    {
        return number;
    }
}
