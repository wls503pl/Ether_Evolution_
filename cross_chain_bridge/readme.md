# Cross-chain bridge

A cross-chain bridge is a blockchain protocol that allows digital assets and information to be moved between two or more blockchains.
For example, an ERC20 token running on the Ethereum mainnet can be transferred to other Ethereum-compatible sidechains or independent chains through a cross-chain bridge.<br>
(At the same time, cross-chain bridges are not natively supported by blockchains, and cross-chain operations require trusted third parties to perform, which also brings risks.
In the past two years, attacks on cross-chain bridges have caused more than $2 billion in user asset losses).

## Types of cross-chain bridges

There are three main types of cross-chain bridges:<br>
- **Burn/Mint**: Destroy (burn) tokens on the source chain, and then create (mint) the same number of tokens on the target chain. The advantage of this method is that the total supply of tokens remains unchanged,
  but the cross-chain bridge needs to have the minting authority of the tokens, which is suitable for projects to build their own cross-chain bridges.<br>

![Burn-Mint_Bridge](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/Burn-Mint_Bridge.png)<br><br>

- **Stake/Mint**: Lock (stake) tokens on the source chain, and then create (mint) the same number of tokens (certificates) on the target chain. The tokens on the source chain are locked,
  and then unlocked when the tokens are moved from the target chain back to the source chain. This is a solution generally used by cross-chain bridges, which does not require any permissions,
  but the risk is also high. When the assets of the source chain are hacked, the certificates on the target chain will become empty.<br>

![Stake-Mint_Bridge](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/Stake-Mint_Bridge.png)<br><br>

- **Stake/Unstake**: Lock (stake) tokens on the source chain, and then release (unstake) the same number of tokens on the target chain. The tokens on the target chain can be exchanged back to the source chain tokens at any time.
  This method requires the cross-chain bridge to have locked tokens on both chains, which has a high threshold and generally requires users to be incentivized to lock tokens on the cross-chain bridge.<br>

![Stake-Unstake_Bridge](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/Stake-Unstake_Bridge.png)<br><br>

<hr>

# Building a simple cross-chain bridge

To better understand this cross-chain bridge, we will build a simple cross-chain bridge and implement the ERC20 token transfer between the Goerli testnet and the Sepolia testnet. We use the burn/mint method,
where the tokens on the source chain will be destroyed and created on the target chain. This cross-chain bridge consists of a smart contract (deployed on both chains) and an Ethers.js script.

## Cross-chain Token Contract

First, we need to deploy an ERC20 token contract, \"CrossChainToken\", on the Goerli and Sepolia testnets. This contract defines the name, symbol, and total supply of the token,
as well as a bridge() function for cross-chain transfers.

This contract has three main functions:
- **constructor()**: The constructor is called once when the contract is deployed to initialize the token's name, symbol, and total supply.
- **bridge()**: The user calls this function for cross-chain transfer, which will destroy the number of tokens specified by the user and release the Bridge event.
- **mint()**: Only the owner of the contract can call this function, which is used to handle cross-chain events and release Mint events. When a user calls the ***bridge()*** function on another chain to destroy tokens,
  the script will listen to the *Bridge* event and mint tokens for the user on the target chain.

## Cross-chain scripts
After we have the token contract, we need a server to handle cross-chain events. We can write an ethers.js script (v6 version) to listen to the Bridge event. When the event is triggered,
the same number of tokens will be created on the target chain.

<hr>

## Remix Demo

- **Step1**: Deploy the **CrossChainToken** contract on the **Goerli** and **Sepolia** test chains respectively. The contract will automatically mint 10,000 tokens.

![deployCrossChainToken](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/deployCrossChainToken.png)<br><br>

- **Step2**: Complete the RPC node URL and administrator private key in the cross-chain script **crosschain.js**, fill in the token contract addresses deployed in **Goerli** and **Sepolia** to the corresponding locations,
  and run the script.

- **Step3**: Call the ***bridge()*** function of the token contract on the Goerli chain to cross-chain 100 tokens.

![bridge](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/bridge.png)<br><br>

- **Step4**: The script listens to the cross-chain event and mints 100 tokens on the **Sepolia** chain.

![runScript](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/runScript.png)<br><br>

- **Step5**: Call ***balance()*** on the **Sepolia** chain to query the balance and find that the token balance has become 10100. The cross-chain is successful!

![CheckBalance](https://github.com/wls503pl/Ether_Evolution_/blob/ee/cross_chain_bridge/img/CheckBalance.png)<br><br>
