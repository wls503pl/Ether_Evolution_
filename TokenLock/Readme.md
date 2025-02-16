# Token Lock

A Token Lock is a simple time-based smart contract that allows one to lock a number of tokens for a certain period of time. After the lock-up period is over,
the beneficiary can then withdraw the tokens. A Token Lock is commonly used to lock LP tokens.

## What is LP token?

In blockchain, users trade tokens on decentralized exchanges (DEX), such as Uniswap. DEX is different from centralized exchanges (CEX). Decentralized exchanges use the automatic market maker (AMM) mechanism,
which requires users or project parties to provide a capital pool so that other users can buy and sell instantly.

Simply put, users/project parties need to pledge the corresponding currency pairs (such as ETH/DAI) into the fund pool. As compensation,
DEX will mint them corresponding liquidity provider LP token certificates to prove that they have pledged the corresponding shares for them to collect service fees.

## Why lock in liquidity?

If the project party withdraws the LP tokens from the liquidity pool without any warning, the tokens in the hands of investors will not be able to be converted into cash and will be directly reduced to zero.
This behavior is also called \"rug-pulling\".(**In 2021 alone, various rug-pull scams have defrauded investors of more than $2.8 billion worth of cryptocurrency!!!**)
However, if the LP tokens are locked in the token lock contract, the project owner cannot withdraw from the liquidity pool or rug pull before the lock period ends. Therefore,
token lock can prevent the project owner from running away prematurely.(**Be careful about the situation where the lock-up period expires and the user runs away!!!!!**)

## Token lock contract

Let's write a contract called TokenLocker to lock ERC20 tokens. Its logic is very simple:<br>
- When deploying the contract, the developer specifies the lock-up time, beneficiary address, and token contract.
- Developers transfer tokens to the TokenLocker contract.
- When the lock-up period expires, the beneficiary can take away the tokens in the contract

## Event

There are 2 events in the TokenLocker contract.
- **TokenLockStart**: lock start event, released when the contract is deployed, records the beneficiary address, token address, lock start time, and end time.
- **Release**: Token release event, released when the beneficiary withdraws the token, records the beneficiary address, token address, token release time, and token quantity.
```
// Event
event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);
```

## State variables

There are 4 state variables in the TokenLocker contract:<br>
- **token**: locked token address
- **beneficiary**: beneficiary address
- **locktime**: lock time (seconds)
- **startTime**: lock start timestamp (seconds)
```
// Locked ERC20 token contract
IERC20 public immutable token;

// Beneficiary address
address public immutable beneficiary;

// Locking time (seconds)
uint256 public immutable lockTime;

// Lock position start timestamp (seconds)
uint256 public immutable startTime;
```

## Function

There are 2 functions in the TokenLocker contract:<br>
- **Constructor**: Initialize the token contract, beneficiary address, and lock time
- **release()**: After the lock-up period expires, the tokens will be released to the beneficiary. The beneficiary needs to actively call the *release()* function to withdraw the tokens
```
/**
 * @dev deploys the time lock contract, initializes the token contract address, beneficiary address and lock time.
 * @param token_: ERC20 token contract to be locked
 * @param beneficiary_: beneficiary address
 * @param lockTime_: lock time (seconds)
 */
constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 lockTime_
    ) {
        require(lockTime_ > 0, "TokenLock: lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;

        emit TokenLockStart(beneficiary_, address(token_), block.timestamp, lockTime_);
    }
```

```
/**
 * @dev After the lock-up time, the tokens are released to the beneficiary.
 */
function release() public {
        require(block.timestamp >= startTime+lockTime, "TokenLock: current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");
        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }
```

# Remix Demo

- **Step1**: Deploy ERC20 contract(token name and symbol set to "ELEW" and "EW" respectively), mint yourself 10,000 tokens.
![DeployERC20Contract](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TokenLock/img/deployERC20.png)

- **Step2**: Deploy the ToeknLocker contract, the token address is the ERC20 contract address, the beneficiary is yourself, and the lock period is 180 seconds.
![DeployTokenLockerContract](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TokenLock/img/deployTokenLocker.png)

- **Step3**: Transfer 10,000 tokens into the contract.
![Transfer10000Tokens](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TokenLock/img/transferTokenToLocker.png)

- **Step4**: If the *release()* function is called within 180 seconds of the lock-up period, the tokens cannot be withdrawn.
![ReleaseWithinLockTime[]()](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TokenLock/img/ReleaseFailed.png)

- **Step5**: Call the *release()* function after the lock-up period to successfully withdraw the tokens.
![Successfully withdraw tokens](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TokenLock/img/successfullyReleased.png)
