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

    /**
     * @dev Return Ethereum Signature Message.
     * 'hash': Message Hash
     * Comply with Ethereum signature standards: https://eth.wiki/json-rpc/API#eth_sign['eth_sign']
     * And 'EIP191':https://eips.ethereum.org/EIPS/eip-191
     * Add "\x19Ethereum Signed Message:\n32" field, preventing the signature from being an executable transaction.
     */
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract SignatureNFT is ERC721
{
    // Signature Address
    address immutable public signer;

    // Record the minted address
    mapping(address => bool) public mintedAddress;

    // Constructor to initialize the name, code, and signature address of the NFT collection
    constructor(string memory _name, string memory _symbol, address _signer) ERC721(_name, _symbol)
    {
        signer = _signer;
    }

    // Verify signature and mint using ECDSA
    function mint(address _account, uint256 _tokenId, bytes memory _signature) external
    {
        // Package _account and _tokenId into a message
        bytes32 _msgHash = getMessageHash(_account, _tokenId);

        // Calculate Ethereum signature message
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash);

        // ECDSA test passed
        require(verify(_ethSignedMessageHash, _signature), "Invalid signature");

        // The address has not been minted
        require(!mintedAddress[_account], "Already minted!");

        // Record the minted address
        mintedAddress[_account] = true;

        // mint
        _mint(_account, _tokenId);
    }

    /*
     * Combine the mint address (address type) and tokenId (uint256 type) into the message msgHash
     * _account: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
     * _tokenId: 0
     * Corresponding message msgHash: 0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
     */
    function getMessageHash(address _account, uint256 _tokenId) public pure returns(bytes32)
    {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    // ECDSA verification, calling the verify() function of the ECDSA library
    function verify(bytes32 _msgHash, bytes memory _signature) public view returns (bool)
    {
        return ECDSA.verify(_msgHash, _signature, signer);
    }
}

/* Signature Verification

How to Sign and Verify
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/

contract VerifySignature
{
    /* 1. Unlock MetaMask account
    ethereum.enable()
    */

    /* 2. Get message hash to sign
    getMessageHash(
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C,
        123,
        "coffee and donuts",
        1
    )

    hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
    */
    function getMessageHash(address _addr, uint256 _tokenId) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(_addr, _tokenId));
    }

    /* 3. Sign message hash
    # using browser
    account = "copy paste account of signer here"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # using web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Signature will be different for different accounts
    0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256
            (
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    /* 4. Verify signature
    signer = 0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd
    to = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
    amount = 123
    message = "coffee and donuts"
    nonce = 1
    signature =
        0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function verify(address _signer, address _addr, uint _tokenId, bytes memory signature) public pure returns (bool)
    {
        bytes32 messageHash = getMessageHash(_addr, _tokenId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        // Check the signature length. 65 is the length of the standard r, s, v signature.
        require(sig.length == 65, "invalid signature length");

        assembly {
            /**
             * First 32 bytes stores the length of the signature add(sig, 32) = pointer of sig + 32
             * effectively, skips first 32 bytes of signature
             * mload(p) loads next 32 bytes starting at the memory address p into memory
             **/

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 0x20))

            // second 32 bytes
            s := mload(add(sig, 0x40))
            
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 0x60)))
        }

        // implicitly return (r, s, v)
    }
}
