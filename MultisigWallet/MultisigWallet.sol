// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Signature-based multi-signature wallet, simplified from the gnosis safe contract
contract MultisigWallet
{
    event ExecutionSuccess(bytes32 txHash);         // transaction successful event
    event ExecutionFailure(bytes32 txHash);         // transaction failure event
    address[] public owners;                        // Multi-signature holder array
    mapping(address => bool) public isOwner;        // record if an address is multi-signature address
    uint256 public ownerCount;                      // Number of multi-signature holders
    uint256 public threshold;   // Multi-signature execution threshold: a transaction can only be executed if it is signed by at least n multi-signatories.
    uint256 public nonce;                           // nonce, preventing signature replay attacks

    receive() external payable {}

    // constructor, initialize owners, isOwner, ownerCount, threshold
    constructor(
        address[] memory _owners,
        uint256 _threshold)
    {
        _setupOwners(_owners, _threshold);
    }

    // @dev initialize owners, isOwner, ownerCount, threshold
    // @param _owners: multi-signature holder array
    // @param _threshold: multi-signature execution threshold, at least several multi-signatories have signed the transaction
    function _setupOwners(address[] memory _owners, uint256 _threshold) internal
    {
        // threshold has not been initialized
        require(threshold == 0, "The threshold has already initialized.");

        // multi-signature execution threshold is less than or equal to the number of multi-signatures
        require(_threshold <= _owners.length, "The threshold is larger than the number of multi-signature holders.");

        // the multi-signer execution threshold is at least 1
        require(_threshold >= 1, "There should be at least 1 multi-signature verification.");

        for (uint256 i = 0; i < _owners.length; i++)
        {
            address owner = _owners[i];

            // The multi-signer cannot be 0 address or the contract address, also cannot be repeated
            require(owner != address(0) && owner != address(this) && !isOwner[owner],
            "The multi-signer cannot be 0 address or the contract address, also cannot be repeated");

            owners.push(owner);
            isOwner[owner] = true;
        }

        ownerCount = _owners.length;
        threshold = _threshold;
    }

    /* 
     * @dev ececute transaction after collecting enough multi-signatures
     * @param, to: Target contract address
     * @param, value: msg.value, number of paid ETH
     * @param, data: calldata, contains function selector and parameters
     * @param, signatures: packed signatures. The corresponding multi-signature address is from small to large,
     * which is convenient for checking. ({bytes32 r}{bytes32 s}{uint8 v}) (Signature of the first multi-signature,
     * signature of the second multi-signature ... )
     */
    function execTransaction(
        address to,
        uint256 value,
        bytes memory data,
        bytes memory signatures
    ) public payable virtual returns (bool success)
    {
        // encode transaction data, calculate Hash
        bytes32 txHash = encodeTransactionData(to, value, data, nonce, block.chainid);
        nonce++;    // As multi-signature contracts are successfully executed, adding nonce

        checkSignatures(txHash, signatures);    // check signatures

        // using call to execute transaction and get transaction result
        (success, ) = to.call{value: value}(data);

        // require(success, "Transfer failed.")
        if (success) emit ExecutionSuccess(txHash);
        else emit ExecutionFailure(txHash);
    }

    /*
     * @dev Check if the signature and transaction data correspond.
     * If it is an invalid signature, the transaction will be reverted.
     * @param: dataHash, transaction data hash
     * @param: signatures, several multi-signatures packaged together
     */
    function checkSignatures(
        bytes32 dataHash,
        bytes memory signatures
    ) public view
    {
        // Read multi-signature execution threshold
        uint256 _threshold = threshold;
        require(_threshold > 0, "There must be one more signatures.");

        // check signature's length is long enough
        // Why 65? multi-signer's signature is 65 Bytes long
        require(signatures.length >= _threshold * 65, "Multi-Signatures are not meet the length of standard.");

        /*
         * Through a loop, check whether the collected signatures are valid
         * Probably the idea:
         * 1. Use ecdsa to verify whether the signature is valid
         * 2. Use currentOwner > lastOwner to determine that the signatures come from different multi-signatures
         * (multi-signature addresses increase in increments)
         * 3. Use isOwner[currentOwner] to determine if the signer is a multi-signature holder
         */
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++)
        {
            (v, r, s) = signatureSplit(signatures, i);
            // using ecrecover to check signature is effective or not.
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v, r, s);
            require(currentOwner > lastOwner && isOwner[currentOwner], "Current Owner is not valid.");
            lastOwner = currentOwner;
        }
    }

    // Separate individual signatures from the packaged signatures.
    // @param signatures packaged multi-signature.
    // @param pos The multi-signature index to read.
    function signatureSplit(bytes memory signatures, uint256 pos) internal pure returns(uint8 v, bytes32 r, bytes32 s)
    {
        // format of signature: {bytes32 r}{bytes32 s}{uint8 v}
        assembly
        {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }

    // @dev Encode transaction data
    // @param to: target contract address
    // @param value: msg.value, the amount of Ethereum paid
    // @param data: calldata
    // @param _nonce: transaction nonce.
    // @param chainid: chain id
    // @return transaction hash bytes.
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        uint256 _nonce,
        uint256 chainid
    ) public pure returns(bytes32)
    {
        bytes32 safeTxHash =
            keccak256(abi.encode(to, value, keccak256(data), _nonce, chainid));
        return safeTxHash;
    }
}