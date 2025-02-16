# Multi-signature wallet

A multi-signature wallet is an electronic wallet that can only be executed after being authorized by multiple private key holders (multi-signers). For example, if a wallet is managed by 3 multi-signers, each transaction requires at least 2 signatures.
Multi-signature wallets can prevent single point failures (private key loss, single person committing evil), are more decentralized, and more secure, and are adopted by many DAOs.

## Multi-signature wallet contract

The multi-signature wallet on Ethereum is actually a smart contract, which belongs to the contract wallet. Let's write a minimalist multi-signature wallet MultisigWallet contract, its logic is very simple:<br>
1. **Setting multi-signers and thresholds (on-chain)**: When deploying a multi-signature contract, we need to initialize the multi-signer list and the execution threshold (a transaction can only be executed after at least **n** multi-signers sign and authorize). The **Gnosis Safe** multi-signature wallet supports adding/deleting multi-signers and changing the execution threshold(but this function is not considered in our minimalist version).

2. **Create a transaction (off-chain)**: A transaction to be authorized contains the following.
- **to**: Target Contract.
- **value**: The amount of Ethereum sent in the transaction.
- **data**: Calldata, contains the selector and parameters of the calling function.
- **nonce**: Initially 0, the value increases with each successful transaction of the multi-signature contract to prevent signature replay attacks.
- **chainid**: Chain id, to prevent signature replay attacks on different chains.

3. **Collect multi-signatures (off-chain)**: Encode the transaction ABI in the previous step and calculate the hash to get the transaction hash, then have multiple signatories sign and splice them together to get the packaged signature.
```
Transaction Hash: 0xc1b055cf8e78338db21407b425114a2e258b0318879327945b661bfdea570e66
Multi-signer A’s signature: 0x014db45aa753fefeca3f99c2cb38435977ebb954f779c2b6af6f6365ba4188df542031ace9bdc53c655ad2d4794667ec2495196da94204c56b1293d0fbfacbb11c
Multi-signer B’s signature: 0xbe2e0e6de5574b7f65cad1b7062be95e7d73fe37dd8e888cef5eb12e964ddc597395fa48df1219e7f74f48d86957f545d0fbce4eee1adfbaff6c267046ade0d81c
Package signature: 0x014db45aa753fefeca3f99c2cb38435977ebb954f779c2b6af6f6365ba4188df542031ace9bdc53c655ad2d4794667ec2495196da94204c56b1293d0fbfacbb11cbe2e0e6de5574b7f65cad1b7062be95e7d73fe37dd8e888cef5eb12e964ddc597395fa48df1219e7f74f48d86957f545d0fbce4eee1adfbaff6c267046ade0d81c
```

4. Call the execution function of the multi-signature contract, verify the signature and execute the transaction (on-chain).

## Event

MultisigWallet contract has 2 Events, ExecutionSuccess and ExecutionFailure. Released when the transaction succeeds or fails, the parameter is the transaction hash.
```
event ExecutionSuccess(bytes32 txHash);      // transaction successful event
event ExecutionFailure(bytes32 txHash);      // transaction failure event
```

## Status Variable

MultisigWallet contract has 5 status variable:<br>
1. **owners**: Multi-signature holder array.
2. **isOwner**: *address => bool* mapping, records whether an address is a multi-signature holder.
3. **ownerCount**: Number of multi-signature holders.
4. **threshold**: Multi-signature execution threshold: a transaction can only be executed if it is signed by at least n multi-signature parties.
5. **nonce**: Initially 0, the value increases with each successful transaction of the multi-signature contract to prevent signature replay attacks.
```
address[] public owners;      // Multi-signature holder array
mapping(address => bool) public isOwner;  // Record whether an address is a multi-signature holder
uint256 public ownerCount;    // Number of multi-signature holders
uint256 public threshold;     // Multi-signature execution threshold: a transaction can only be executed if it is signed by at least n multi-signature parties
uint256 public nonce;         // nonce, preventing signature replay attacks
```

## Function

MultisigWallet has 6 functions:
1. ***Constructor***: call *_setupOwner()*, initialize variables related to multi-signature holders and execution thresholds.
```
// constructor, initialize owners, isOwner, ownerCount, threshold
constructor(address[] memory _owners, uint256 _threshold)
{
  _setupOwners(_owners, _threshold);
}
```

2. ***_setupOwners()***: It is called by the ***constructor*** when the contract is deployed to initialize the **state variables** of owners, isOwner, ownerCount, and threshold. Among the parameters passed in, the execution threshold must be greater than or equal to **1** and less than or equal to the number of multi-signatures; the multi-signature address cannot be 0 and cannot be repeated.

3. ***execTransaction()***: After collecting enough **multi-signatures**, verify the signatures and execute the transaction. The parameters passed in are the target address **to**, the amount of Ethereum to be sent **value**, the data **data**, and the packaged signatures **signatures**. Packaged signatures are to package the collected multi-signature signatures on the transaction hash into a [bytes] data in ascending order of the multi-signature holder address. This step calls ***encodeTransactionData()*** to encode the transaction and calls ***checkSignatures()*** to check whether the signature is valid and whether the quantity reaches the execution threshold.

4. ***checkSignatures()***: Checks whether the signature corresponds to the hash of the transaction data and whether the quantity reaches the threshold. If not, the transaction will be reverted. The length of a single signature is 65 bytes, so the length of the packaged signature must be longer than or equal to threshold * 65. Call signatureSplit() to separate a single signature. The general idea of ​​this function is:
- Get the signature address with **ecdsa**.
- Use **currentOwner > lastOwner** to determine that the signature comes from different multi-signatures (multi-signature addresses increase in increments).
- Use **isOwner[currentOwner]** to determine if the signer is a multi-signature holder.

5. ***signatureSplit()***: separates a single signature from the packaged signature. The parameters are the packaged signatures and the signature position pos to be read. Inline assembly is used to separate the three values ​​of r, s, and v of the signature.

6. ***encodeTransactionData()***: Pack the transaction data and calculate the hash, using the abi.encode() and keccak256() functions. This function can calculate the hash of a transaction, then have multiple signatories sign and collect it off-chain, and then call the *execTransaction()* function to execute it.
