# ERC20

The most popular token standard on Ethereum. One of the main reasons for its popularity is the use of ***approve*** and ***transferFrom*** functions together,
which allows tokens to be transferred not only between externally owned accounts (EOAs), but also used by other contracts.

However, the **ERC20** approve function is limited to token owners, which means that all initial operations of ERC20 tokens must be performed by **EOA**.<br>
For example, if user A uses USDT to exchange ETH on a decentralized exchange, two transactions must be completed:<br>
the first step is for user A to call approve to authorize the contract with USDT, and the second step is for user A to call the contract to exchange.
This is very troublesome, and the user must hold ETH to pay for the gas of the transaction.

## ERC20Permit

EIP-2612 proposed ERC20Permit, which extends the ERC20 standard and adds a permit function that allows users to modify authorization through EIP-712 signatures instead of msg.sender.
This has two benefits:<br>
1. The authorization step only requires the user to sign off-chain, reducing one transaction.
2. After signing, users can entrust a third party to perform subsequent transactions without holding ETH: User A can send the signature to a third party B who has gas and entrust B to perform subsequent transactions.<br>

![ERC20vsPermit](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC2612_ERC20Permit/img/ERC20vsPermit.png)<br><br>

## IERC20Permit Interface Contract 

It defines 3 functions:
- ***permit()***: According to the signature of owner, owenr's ERC20 token balance is authorized to spender, the amount is value. Requirement:
  - spender: it is not address 0.
  - deadline: Must be a timestamp in the future.
  - v, r and s must be a valid keccak256 signature of the owner for the function parameters in EIP712 format
  - The signature must use the owner's current nonce.
- ***nonces()***: Returns the current nonce of the owner. This value must be included every time a signature is generated for the permit() function.
  Each successful call to the permit() function will increase the owner's nonce by 1 to prevent the same signature from being used multiple times.
- ***DOMAIN_SEPARATOR()***: Returns the domain separator used to encode the signature of the permit() function, as defined in EIP712.

## ERC20Permit Contract

Contract contains 2 status variables:
- **_nonces**: The mapping of \"address -> uint\" records the current nonce values ​​of all users.
- **_PERMIT_TYPEHASH**: Constant that records the type hash of the ***permit()*** function.

The contract contains 5 functions:
- ***Constructor***: Initialize the **name** and **symbol** of the token.
- ***permit()***: The core function of ERC20Permit, which implements ***permit()*** of IERC20Permit. It first checks whether the signature is expired, then restores the signed message with
  **_PERMIT_TYPEHASH**, **owner**, **spender**, **value**, **nonce**, **deadline**, and verifies whether the signature is valid. If the signature is valid, it calls the ERC20 ***_approve()*** function for authorization.
- ***nonces()***: Implemented IERC20Permit’s ***nonces()*** function.
- ***DOMAIN_SEPARATOR()***: Implemented the DOMAIN_SEPARATOR() function of IERC20Permit.
- ***_useNonce()***: The function that consumes nonce returns the user's current nonce and increases it by 1.

<hr>

# Remix Reproduction

1. Deploy the **ERC20Permit** contract and set both **name** and **symbol** to **WTFPermit**.
   <br><br>
   ![DeployERC20Permit](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC2612_ERC20Permit/img/DeployERC20Permit.png)<br><br>
    
2. Run **signERC20Permit.html**, change **Contract Address** to the deployed ERC20Permit contract address, and other information is given below.
   Then click **Connect Metamask** and **Sign Permit** buttons to sign, and get r, s, v for contract verification. To sign, use the wallet that deployed the   contract, such as the Remix test wallet:
   ```
   owner: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4    spender: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
   value: 100
   deadline: 115792089237316195423570985008687907853269984665640564039457584007913129639935
   private_key: 503f38a9c967ed597e47fe25643985f032b072db8075426a92110f82df48dfcb
   ```

   ![signERC20Permit_html](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC2612_ERC20Permit/img/signERC20Permit_html.png)<br>
   ![AfterSignature](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC2612_ERC20Permit/img/AfterSignature.png)<br><br>
   
3. Call the contract's ***permit()*** method and enter the corresponding parameters for authorization.
   <br><br>
   ![callPermit](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC2612_ERC20Permit/img/callPermit.png)<br><br>
4. Call the ***allowance()*** method of the contract, enter the corresponding **owner** and **spender**, and you can see that the authorization is successful.
   <br><br>
   ![callAllowance](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC2612_ERC20Permit/img/callAllowance.png)<br><br>

## Safety Tips

ERC20Permit uses off-chain signatures for authorization, which brings convenience to users, but also brings risks. Some hackers will use this feature to conduct phishing attacks,
defraud users of signatures and steal assets. A signature phishing attack against USDC in April 2023 caused a user to lose 228w u of assets.<br>
**When signing, be sure to read the signature carefully!**
<br>
At the same time, some contracts will also bring DoS (Denial of Service) risks when integrating permit. Because permit will use up the current nonce value when executed,
if the contract function contains **permit** operations, the attacker can execute permit by preemptively executing it, causing the target transaction to roll back because the nonce is occupied.

## Summarize

Introduced ERC20Permit, an extension of the ERC20 token standard, which supports users to use off-chain signatures for authorization operations, improves user experience, and is adopted by many projects.
But at the same time, it also brings greater risks. One signature can take away your assets. Everyone must be more cautious when signing.
