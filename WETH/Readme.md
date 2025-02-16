# What's "WETH"?

WETH (Wrapped ETH) is a wrapped version of ETH. Common WETH, WBTC, and WBNB are all wrapped native tokens. So why do we wrap them?<br>
<br>
In 2015, the ERC20 standard emerged, which aims to establish a standardized set of rules for tokens on Ethereum, thereby simplifying the issuance of new tokens and making all tokens on the blockchain comparable to each other.<br>
Unfortunately, Ethereum itself does not conform to the ERC20 standard. WETH was developed to improve interoperability between blockchains and make ETH usable for decentralized applications (dApps).<br>
It is like putting a smart contract on the native token: when the clothes are put on, it becomes WETH, which conforms to the ERC20 homogeneous token standard, can cross chains, and can be used in dApps;<br>
when the clothes are taken off, it can be exchanged for ETH 1:1.

## WETH Contract

The current mainnet WETH contract was written in 2015 and is very old. At that time, Solidity was version 0.4. We rewrote a WETH contract using version 0.8.<br>
WETH complies with the ERC20 standard and has two more functions than ordinary ERC20:<br>
1. **Deposit:** Wrapping, users deposit ETH into the WETH contract and receive an equal amount of WETH.<br>
2. **Withdrawal:** Unpacking, user destroys WETH and gets an equal amount of ETH.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20
{
  // Event, deposit and withdraw
  event  Deposit(address indexed dst, uint amount);
  event  Withdrawal(address indexed src, uint amount);

  // Constructor, initialize the name and code of ERC20
  constructor() ERC20("WETH", "WETH") {}

  //Callback function, when the user transfers ETH to the WETH contract, the deposit() function will be triggered
  fallback() external payable
  {
    deposit();
  }

  //Callback function, when the user transfers ETH to the WETH contract, the deposit() function will be triggered
  receive() external payable
  {
    deposit();
  }

  // Deposit function, when the user deposits ETH, mint the same amount of WETH for him
  function deposit() public payable
  {
    _mint(msg.sender, msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  // Withdrawal function, the user destroys WETH and withdraws an equal amount of ETH
  function withdraw(uint amount) public
  {
    require(balanceOf(msg.sender) >= amount);
    _burn(msg.sender, amount);
    payable(msg.sender).transfer(amount);
    emit Withdrawal(msg.sender, amount);
  }
}
```

## Inheritance

WETH complies with the ERC20 token standard, so the WETH contract inherits the ERC20 contract

## Event

There are 2 events in the WETH contract:<br>
1. **Deposit:** Deposit event, released when a deposit is made.<br>
2. **Withdraw:** Withdraw event, released when withdrawing money.

## Function

In addition to the ERC20 standard functions, the WETH contract has 5 functions:<br>
- **Constructor**: Initialize the name and code of WETH.<br>
- **Callback functions**: *fallback()* and *receive()*, when a user transfers ETH to the WETH contract, the deposit() function will be automatically triggered to obtain an equal amount of WETH.<br>
- **deposit()**: Deposit function. When a user deposits ETH, an equal amount of WETH is minted for him.<br>
- **withdraw()**: Withdrawal function, allowing users to destroy WETH and return an equal amount of ETH.

# Remix Demo

1. Call *deposit*, deposit 1 ETH, and check the WETH balance
![deposit 1 ETH](https://github.com/wls503pl/Ether_Evolution_/blob/ee/WETH/img/deposit1ETH.png)

![balance of 1 WETH](https://github.com/wls503pl/Ether_Evolution_/blob/ee/WETH/img/balance1WETH.png)

2. Transfer 1 ETH directly to the WETH contract and check the WETH balance, at this time, the WETH balance is 2 WETH
![Transfer 1ETH to WETH contract](https://github.com/wls503pl/Ether_Evolution_/blob/ee/WETH/img/lower_Call.png)

3. Call withdraw, withdraw 1.5 ETH, and check the WETH balance, the WETH balance at this time is 0.5 WETH
![After withdraw](https://github.com/wls503pl/Ether_Evolution_/blob/ee/WETH/img/withrawWETH.png)
