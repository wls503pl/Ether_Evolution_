// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC20/IERC20.sol";
import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC20/ERC20.sol";

/**
 * @dev ERC20 token time lock contract. The beneficiary can only withdraw the token after locking it for a period of time.
 */
contract TokenLocker
{
    // Event
    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    // Locked ERC20 token contract
    IERC20 public immutable token;

    // Beneficiary address
    address public immutable beneficiary;

    // Locking time (seconds)
    uint256 public immutable lockTime;

    // Lock position start timestamp (seconds)
    uint256 public immutable startTime;

    /**
     * @dev deploys the time lock contract, initializes the token contract address, beneficiary address and lock time.
     * @param token_: ERC20 token contract to be locked
     * @param beneficiary_: beneficiary address
     * @param lockTime_: lock time (seconds)
     */
    constructor(IERC20 token_, address beneficiary_, uint256 lockTime_)
    {
        require(lockTime_ > 0, "TokenLock: lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;

        emit TokenLockStart(beneficiary_, address(token_), block.timestamp, lockTime_);
    }

    /**
     * @dev After the lock-up time, the tokens are released to the beneficiary.
     */
    function release() public
    {
        require(block.timestamp >= startTime+lockTime, "TokenLock: current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");
        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }
}
