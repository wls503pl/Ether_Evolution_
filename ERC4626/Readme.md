# Preface

It is often said that DeFi is a currency Lego, and new protocols can be created by combining multiple protocols; however, the lack of standards in DeFi seriously affects its composability. 
ERC4626 extends the ERC20 token standard and aims to promote the standardization of yield vaults.

## Treasury

The Treasury contract is the foundation of DeFi Lego. It allows you to stake underlying assets (tokens) into the contract in exchange for certain returns,
including the following application scenarios:
- **Yield Farming**: In \"Yearn Finance\", you can stake USDT to earn interest.
- **Lending**: In \"AAVE\", you can lend ETH to get deposit interest and loans.
- **Staking**: In \"Lido\", you can stake ETH to participate in ETH 2.0 staking and get interest-bearing stETH.


## ERC4626

Since vault contracts lack standards and are written in a variety of ways, a yield aggregator needs to write many interfaces to connect to different DeFi projects.
The ERC4626 Tokenized Vault Standard has emerged, making DeFi easy to expand. It has the following advantages:
1. Tokenization: ERC4626 inherits ERC20. When you deposit money into the treasury, you will get a share of the treasury that also complies with the ERC20 standard. For example, if you pledge ETH, you will automatically get stETH.
2. Better liquidity: Due to tokenization, you can use your vault share to do other things without taking back the underlying asset. Take Lido’s stETH as an example, you can use it to provide liquidity or trade on Uniswap without taking out the ETH in it
3. Better composability: With the standard, a set of interfaces can be used to interact with all ERC4626 vaults, making it easier to develop vault-based applications, plug-ins, and tools.

All in all, ERC4626 is as important to DeFi as ERC721 is to NFT.

## ERC4626 Essentials

The ERC4626 standard mainly implements the following logics:
1. ERC20: ERC4626 inherits ERC20, and the vault share is represented by ERC20 tokens: when a user deposits a specific ERC20 underlying asset (such as WETH) into the vault, the contract will mint a specific number of vault share tokens for him;
   when the user withdraws the underlying asset from the vault, the corresponding number of vault share tokens will be destroyed. The asset() function returns the token address of the vault's underlying asset.
2. Deposit logic: Allow users to deposit underlying assets and mint the corresponding number of treasury shares. The relevant functions are deposit() and mint(). The deposit(uint assets, address receiver) function allows users to deposit assets in units of assets and mint the corresponding number of treasury shares to the receiver address.
   mint(uint shares, address receiver) is similar to it, except that it takes the minted treasury shares as parameters.
3. Withdrawal logic: Allow users to destroy the vault share and withdraw the corresponding amount of underlying assets in the vault. The relevant functions are withdraw() and redeem(). The former takes the amount of underlying assets to be withdrawn as a parameter,
   and the latter takes the destroyed vault share as a parameter.
4. Accounting and Limit Logic: Other functions in the ERC4626 standard are to count the assets in the vault, deposit/withdrawal limits, and the number of base assets and vault shares deposited/withdrawn.

## IERC4626 Interface Contract

The IERC4626 interface contract contains 2 events:
- **Deposit** event: triggered when a deposit is made.
- **Withdraw** event: triggered when withdrawing money.
The IERC4626 interface contract also contains 16 functions, which are divided into 4 categories according to their functions: metadata, deposit/withdrawal logic, accounting logic, and deposit/withdrawal limit logic.
- Meta data
  - **asset()**: Returns the underlying asset token address of the vault, used for deposits and withdrawals.
- Deposit/Withdrawal Logic
  - **deposit()**: Deposit function, the user deposits the underlying asset in the asset unit into the vault, and then the contract casts the vault quota in the share unit to the receiver address. The Deposit event will be released.
  - **mint()**: Minting function (also deposit function), the user specifies the treasury quota in shares that the user wants to obtain, and the function calculates the number of underlying assets in assets that need to be deposited.
    The contract then transfers the underlying assets in assets from the user's account and mints the specified amount of treasury quota to the receiver address. The Deposit event is released.
  - **withdraw()**: Withdrawal function, the owner address destroys the treasury quota of the share unit, and then the contract sends the corresponding amount of basic assets to the receiver address.
  - **redeem()**: redemption function (also withdrawal function), the owner address destroys the treasury quota of the number of shares, and then the contract sends the corresponding unit of underlying assets to the receiver address.
- Accounting Logic
  - ***totalAssets()***: Returns the total amount of underlying asset tokens managed in the vault.
  - ***convertToShares()***: Returns the amount of treasury that can be exchanged for a certain amount of underlying assets.
  - ***convertToAssets()***: Returns the underlying assets that can be exchanged for a certain amount of treasury quota.
  - ***previewDeposit()***: It is used to simulate the amount of treasury that users can obtain by depositing a certain amount of basic assets in the current on-chain environment.
  - ***previewMint()***: It is used by users to simulate the amount of basic assets required to deposit a certain amount of vault quota in the current on-chain environment.
  - ***previewWithdraw()***: It is used by users to simulate the withdrawal of a certain amount of underlying assets in the current on-chain environment and the vault share that needs to be redeemed.
  - ***previewRedeem()***: It is used by on-chain and off-chain users to simulate the destruction of a certain amount of vault quota in the current on-chain environment to redeem the amount of basic assets.
- Deposit/Withdrawal Limit Logic
  - maxDeposit(): Returns the maximum amount of underlying assets that can be deposited in a single deposit at a certain user address.
  - maxMint(): Returns the maximum amount of treasury that can be minted in a single mint at a certain user address.
  - maxWithdraw(): Returns the maximum amount of underlying assets that can be withdrawn in a single withdrawal from a certain user address.
  - maxRedeem(): Returns the maximum amount of treasury that can be destroyed in a single redemption of a user address

## ERC4626 Contract

Next, we implement a minimalist tokenized vault contract:
- The constructor initializes the contract address of the underlying asset, the token name and symbol of the treasury share. Note that the token name and symbol of the treasury share should be related to the underlying asset.
  For example, if the underlying asset is called WTF, the treasury share should be called.
- When a user deposits x units of underlying assets into the treasury, x units (equal amounts) of treasury shares will be minted.
- When withdrawing funds, when a user destroys x units of the treasury share, x units (equal amount) of the underlying assets will be withdrawn.
**Note**: In actual use, be especially careful about whether the calculation of accounting logic related functions is rounded up or down. You can refer to the implementation of openzeppelin and solmate. This section does not consider it in the teaching example.

<hr>

# Remix Demo

**Note**: The following run example uses the second account in remix, \"0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2\", to deploy the contract and call the contract method.

- **Step1**: Deploy an **\"ERC20\"** token contract, set the token name and symbol to **\"WTF\"**, and mint 10,000 tokens for yourself.
<br><br>
![DeployERC20](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/DeployERC20.png)<br><br>
![mint10000](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/mint10000.png)<br><br>

- **Step2**: Deploy the **\"ERC4626\"** token contract, set the contract address of the underlying asset to the \"address of WTF\", and set the name and symbol to **vWTF**.
<br><br>
![DeployERC4626](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/DeployERC4626.png)<br><br>

- **Step3**: Call the ***approve()*** function of the ERC20 contract to authorize the token to the ERC4626 contract.
<br><br>
![approveToERC4626](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/approveToERC4626.png)<br><br>

- **Step4**: Call the ***deposit()*** function of the ERC4626 contract to deposit 1000 tokens. Then call the ***balanceOf()*** function to check that your share of the vault has become 1000.
<br><br>
![ERC4626deposit](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/ERC4626deposit.png)<br><br>

- **Step5**: Call the ***mint()*** function of the ERC4626 contract to deposit 1000 tokens. Then call the ***balanceOf()*** function to check that your share of the vault has become 2000.
<br><br>
![ERC4626mint](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/ERC4626mint.png)<br><br>

- **Step6**: Call the ***withdraw()*** function of the ERC4626 contract to withdraw 1000 tokens. Then call the ***balanceOf()*** function to check that your share of the vault has become 1000.
<br><br>
![ERC4626withdraw](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/ERC4626withdraw.png)<br><br>

- **Step7**: Call the ***redeem()*** function of the ERC4626 contract to withdraw 1,000 tokens. Then call the ***balanceOf()*** function to check that your share of the vault has become 0.
<br><br>
![ERC4626redeem](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC4626/img/ERC4626redeem.png)<br><br>
