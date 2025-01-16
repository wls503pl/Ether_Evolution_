# What is Ethereum?

Ethereum is a global open source platform for decentralized applications. It can be imagined as a world computer that never stops.<br>
On Ethereum, software developers can write smart contracts, which control digital value through a set of standards. Decentralized applications (Dapps) that provide so-called DeFi financial services.<br>
Smart contracts written by software engineers are components of these Dapps. These smart contracts are deployed to the Ethereum network and run 24 hours a day in the network. The network continuously maintains the digital value ledger and tracks its latest status.

## What are smart contracts?

Smart contracts are programmable contracts that allow trading partners to set trading conditions and execute transactions without trusting a third party.

## What is Ether (ETH)?

Ether is the native digital currency of the Ethereum blockchain. Ether acts like currency and is similar to Bitcoin and can be used for daily transactions.<br>
Ether can be sent to another person to purchase goods and services based on current market prices. The Ethereum blockchain records these transactions and ensures that they are immutable.<br>

In addition, Ether is also used to pay for the operation of smart contracts and Dapps in the Ethereum network(Think of executing smart contracts on the Ethereum network as driving a car, fuel is needed).<br>
In order to execute smart contracts on Ethereum, you need to pay a fee called **Gas** in Ether.<br>
Currently, in the DeFi ecosystem, Ethereum is the preferred asset for many DeFi Dapps’ underlying collateral. It provides security and transparency for this financial system.

## What is Gas?

On Ethereum, all transactions and contract executions require a small fee. This fee is called Gas. Technically speaking, Gas refers to a unit of measurement of the computational resources required to execute an operation or a smart contract. The more complex the operation being executed, the more Gas is required to complete it. <u>Gas fees are paid entirely in ETH</u>.

- Gas Fee‘s Characteristics
  - The price of Gas fluctuates from time to time depending on the current network demand. Since computing resources on the network are limited, if more people interact on the Ethereum blockchain,<br>
    such as transferring ETH or executing smart contracts, then the price of Gas will increase. Conversely, if the network is not fully utilized, then the market price of Gas will decrease.<br>
  - Gas fees can be set manually. In the event of network congestion due to high utilization, transactions with the highest gas fees will be verified first.<br>
    Verified transactions will be finalized and added to the blockchain. If the gas fee is set too low, the transaction will enter the waiting queue and take some time to be packaged.<br>
    Therefore, transactions with lower-than-average gas fees take longer to complete.

<hr>

## What is a decentralized application (Dapp)?

In the Ethereum network, Dapp is an interface that interacts with the blockchain through the use of smart contracts. From the front end, Dapp looks and operates similar to regular web applications and mobile applications, except that they interact with the blockchain in different ways.

### What are the advantages of Dapp?

- **Immutability:** Once information is saved on the blockchain, it cannot be changed by anyone;<br>
- **Tamper-proof:** Smart contracts published on the blockchain cannot be tampered with without the knowledge of other participants on the blockchain;<br>
- **Transparency:** Smart contract-driven Dapps are publicly auditable;<br>
- **Availability:** As long as the Ethereum network remains active, Dapps built on it will remain active and available.<br>

### What are the disadvantages of Dapp?

- **Immutability:** Smart contracts are written by humans, so human errors are inevitable, and immutable smart contracts may amplify errors.<br>
- **Transparency:** Publicly auditable smart contracts can also become a medium for hacker attacks, because hackers can find contract vulnerabilities by viewing the code;<br>
- **Scalability:** In most cases, the bandwidth of a Dapp is limited by the blockchain it resides on.<br>

## What else can Ethereum do?

In addition to creating Dapps, Ethereum has two other functions: creating decentralized autonomous organizations (DAOs) or issuing other cryptocurrencies.<br>
- DAO<br>
  It is a fully autonomous organization that is not managed by individuals, but rather by code. The code is run based on smart contracts,<br>
  allowing DAO to replace the typical operating model of traditional institutions. Since it runs on code, it will be free from human intervention and will operate transparently without any outside influence.<br>
  The management decisions or rulings of the DAO will be decided by voting with DAO tokens.

- Token<br>
  Ethereum can be used as a platform to create other cryptocurrencies. Currently, there are two popular token protocols on the Ethereum network:<br>
  - ERC-20:<br>
    ERC-20 tokens are fungible tokens, meaning that they are interchangeable and have the same value.<br>
  - ERC-721:<br>
    ERC-721 tokens are non-fungible tokens, meaning that the tokens are unique and non-interchangeable.<br>

  A simple analogy is to think of ERC-20 as currency and ERC-721 as collectibles like figurines or baseball cards.<br>

## Decentralized Stablecoins

The price of cryptocurrencies is very volatile. To mitigate this volatility, stablecoins whose prices are anchored to stable assets such as the US dollar were created.<br>
Stablecoins can help users hedge against cryptocurrency price fluctuations and serve as a reliable medium of exchange. Stablecoins have since quickly evolved into a powerful component of DeFi and become the key to this modular ecosystem.

### Main categories of stablecoins

Not all stablecoins are the same, as they use different mechanisms to peg to the US dollar. There are two types of pegs, fiat-collateralized and crypto-collateralized.<br>
Most stablecoins use a fiat-collateralized system to maintain their peg to the US dollar.

- Tether(USDT)
Tether is pegged to $1 by holding $1 in reserves for every Tether token minted. Although Tether is the largest and most widely used stablecoin, with an average daily trading volume of approximately $30 billion in January 2020,<br>
Tether's reserves are held in financial institutions, and users have to trust that Tether as an entity actually has the amount of reserves it claims. Therefore, Tether is a **centralized, fiat-collateralized stablecoin**.

- Dai
Dai (DAI), on the other hand, is collateralized by cryptocurrencies such as ETH. The value of Dai is pegged to $1 through a protocol and smart contracts voted on by a decentralized autonomous organization.<br>
At any given time, the collateral used to generate DAI can be easily verified by users. DAI is a **decentralized, cryptocurrency-collateralized stablecoin**.

DAI is the most widely used native stablecoin in the DeFi ecosystem. DAI is the preferred USD stablecoin in DeFi transactions, DeFi lending and other fields.
<hr>

## Platforms that issue DAI

The platform that issues DAI is **Maker**.

### What is Maker?

Maker is a smart contract platform that runs on the Ethereum blockchain. Maker has three tokens:<br>
1.  **Sai:** Also known as Single Collateral Dai, backed only by Ether (ETH) as collateral;
2.  **DAI:** Called Multi-Collateral Dai, Dai is currently backed by Ethereum (ETH) and Basic Attention Token (BAT) as collateral, with plans to add other types of assets as collateral in the future.<br>
    Stablecoins Sai and Dai (both algorithmically pegged to $1);
3.  **MKR:** Maker is the governance token of Maker, which users can use to vote for improvements to the Maker platform through Maker Improvement Proposals<br>
    (Maker belongs to a class of organizations called decentralized autonomous organizations (DAOs)).<br>

Going forward, Multi-Collateral Dai will become the de facto stablecoin standard maintained by Maker, and eventually, SAI will be phased out and no longer supported by Maker.

### How does Maker conduct system governance?

MKR holders have voting rights in this DAO organization proportional to the number of MKR tokens they hold, and can vote on the parameters of the governance Maker protocol.<br>
Three key parameters:<br>
1.  **Mortgage Rate:** The amount of **Dai** that can be minted depends on the collateralization ratio.<br>
- Ether (ETH) Collateral Ratio                  = 150%
- Basic Attention Token (BAT) Collateral Rate   = 150%
<br>
Essentially, a 150% collateralization ratio means that to mint $100 of Dai, you need to collateralize at least $150 worth of **ETH** or **BAT**.<br>

2. **Stability Fee:** The stability fee is equivalent to the “interest rate” that borrowers have to pay in addition to the principal of the Maker vault debt(As of February 2020, the stability fee is 8%).<br>
3. **Dai Deposit Rate (DSR):** The Dai Deposit Rate (DSR) is the interest earned after holding Dai for a period of time. It also acts as a monetary tool to influence the demand for Dai(As of February 2020, the Dai savings rate is 7.50%).<br>

DSR(of MakerDAO) could be found in [!DAI Savings Rate](https://summer.fi/)

## Purpose of issuing DAI

Why would you lock up more valuable ETH or BAT to issue less valuable Dai instead of just selling your crypto assets for USD?<br>
There are three possible scenarios here:<br>
1.  You need cash now and own a crypto asset that you believe will appreciate in value in the future.<br>
- In this scenario, you can deposit your crypto assets into the Maker vault and get immediate access to funds through the issuance of Dai.<br>

2. You need cash now but don’t want to risk triggering a tax event by selling your crypto assets.<br>
- You can withdraw loans by issuing Dai.<br>

3. Investment Leverage.<br>
- Given the belief that your crypto assets will appreciate, you can leverage your assets.<br>

## How can I get some Dai (DAI)?

1. Minting Dai.<br>
- You will mint or "borrow" Dai on the Maker platform by pledging your Ether (ETH) or Basic Attention Token (BAT). When you want to redeem your ETH or BAT after the loan ends, you must repay your "loan" and "loan interest", which is the stability fee.<br>
- On the Maker platform [oasis](www.oasis.app), you can borrow Dai by depositing your ETH or BAT into a vault. Assuming that ETH is currently worth $150, you can lock 1 ETH into a vault and get up to 100 DAI ($100) at a collateral rate of 150%.<br>
- The amount you withdraw should not exceed the maximum amount of 100 DAI, but should leave some buffer for the case of a drop in ETH price. It is recommended to reserve more space to ensure that your collateral ratio is always above 150%. This will ensure that in the event of a drop in ETH price (causing a drop in collateral ratio), your vault will not be liquidated and charged a 13% liquidation penalty.<br>

2. Trading DAI.<br>
- Some users may send their DAI to cryptocurrency exchanges. Therefore, you can also buy DAI from these secondary markets without minting them (Buying DAI on the secondary market is easier because you don’t have to lock up collateral and don’t have to worry about collateralization rates and stability fees).<br>
