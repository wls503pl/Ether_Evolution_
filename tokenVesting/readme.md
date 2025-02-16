# Token Vesting Terms

In the traditional financial sector, some companies offer equity to employees and management. However, releasing a large amount of equity at the same time will create selling pressure in the short term, dragging down stock prices.
Therefore, companies often introduce a vesting period to delay ownership of committed assets.<br>
Similarly, in the blockchain field, Web3 startups will allocate tokens to the team and sell them to venture capital and private equity at low prices. If they put these low-cost tokens on exchanges at the same time to cash out,
the price of the tokens will be smashed, and retail investors will directly become the buyers.<br>
Therefore, project owners generally agree on token vesting terms, gradually releasing tokens during the vesting period to reduce selling pressure and prevent the team and capital from closing down too early.<br>

## Linear Release

Linear release means that tokens are released at a uniform rate during the vesting period. For example, if a private placement holds 365,000 \"UCC\" tokens and the vesting period is 1 year (365 days), 1,000 tokens will be released every day.<br>
Next, we will write a contract called TokenVesting that locks and linearly releases ERC20 tokens. Its logic is very simple:<br>
- The project owner specifies the starting time, vesting period and beneficiaries of linear release.<br>
- The project party transfers the locked ERC20 tokens to the TokenVesting contract.<br>
- The beneficiary can call the release function to take out the released tokens from the contract.<br>

## Event

There is a total of 1 event in the linear release contract.
- **ERC20Released**: Withdrawal event, released when the beneficiary withdraws the released token.
```
contract TokenVesting
{
  // Event
  event ERC20Released(address indexed token, uint256 amount);      // Withdrawal event
}
```

## State variables

There are 4 state variables in the linear release contract:<br>
- **beneficiary**: beneficiary address.<br>
- **start**: the starting timestamp of the vesting period.<br>
- **duration**: vesting period, in seconds.<br>
- **erc20Released**: Token address->Released quantity mapping, recording the number of tokens the beneficiary has received.
```
// State variables
mapping(address => uint256) public erc20Released;    // Token address->Released quantity mapping, record the released tokens
address public immutable beneficiary;                // beneficiary address
uint256 public immutable start;                      // start timestamp
uint256 public immutable duration;                   // vesting period
```
## Function

There are 3 functions in the linear release contract:<br>
- **Constructor**: Initialize beneficiary address, vesting period (seconds), start timestamp. Parameters are beneficiary address beneficiaryAddress and vesting period durationSeconds.<br>
  For convenience, the start timestamp uses the blockchain timestamp block.timestamp when deployed.
- **release()**: function to extract tokens, transfer the released tokens to the beneficiary. The vestedAmount() function is called to calculate the amount of tokens that can be extracted,<br>
  release the ERC20Released event, and then transfer the tokens to the beneficiary. The parameter is the token address token.
- **vestedAmount()**: Query the number of tokens that have been released according to the linear release formula. Developers can customize the release method by modifying this function. The parameters are the token address token and the query timestamp.

<hr>

## Remix Demo

Deploy the ERC20 contract and mint 10,000 tokens for yourself.
![DeployERC20](https://github.com/wls503pl/Ether_Evolution_/blob/ee/tokenVesting/img/deployERC20.png)
![Miint10000](https://github.com/wls503pl/Ether_Evolution_/blob/ee/tokenVesting/img/mint10000Tokens.png)

Deploy the TokenVesting linear release contract, set the beneficiary to yourself, and set the vesting period to 100 seconds.
![deployTokenVesting](https://github.com/wls503pl/Ether_Evolution_/blob/ee/tokenVesting/img/deployTokenVesting.png)

Transfer 10,000 ERC20 tokens to the linear release contract.
![transfer10000toLinerRelease](https://github.com/wls503pl/Ether_Evolution_/blob/ee/tokenVesting/img/transfer10000toLinerRelease.png)

Call release() function to extract tokens.
![ReleaseTokens](https://github.com/wls503pl/Ether_Evolution_/blob/ee/tokenVesting/img/release.png)
