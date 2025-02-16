// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC20/ERC20.sol";

/**
 * @title ERC20 token linear release
 * @dev This contract will linearly release ERC20 tokens to the beneficiary `_beneficiary`.
 * The released tokens can be one or more. The release period is defined by the start time `_start` and the duration `_duration`.
 * All tokens transferred to this contract will follow the same linear release period, and the beneficiary needs to call the `release()` function to extract.
 * The contract is simplified from OpenZeppelin's VestingWallet.
 */
contract TokenVesting
{
    // Event
    event ERC20Released(address indexed token, uint256 amount);         // Withdrawal event

    // Status variables

    // Token address->Released quantity mapping, recording the number of tokens the beneficiary has received
    mapping(address => uint256) public erc20Released;

    address public immutable beneficiary;       // beneficiary address
    uint256 public immutable start;             // vesting period start timestamp
    uint256 public immutable duration;          // vesting period (seconds)

    /**
     * @dev Initialize beneficiary address, release period (seconds), start timestamp (current blockchain timestamp)
     */
    constructor(
        address beneficiaryAddress,
        uint256 durationSeconds
    ) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        start = block.timestamp;
        duration = durationSeconds;
    }

    /**
     * @dev The beneficiary withdraws the released tokens.
     * Call the vestedAmount() function to calculate the amount of tokens that can be withdrawn, and then transfer them to the beneficiary.
     * Release the {ERC20Released} event.
     */
    function release(address token) public
    {
        // Call vestedAmount() function to calculate the number of tokens that can be withdrawn
        uint256 releasable = vestedAmount(token, uint256(block.timestamp)) - erc20Released[token];
        // Update the number of released tokens
        erc20Released[token] += releasable;
        // Transfer tokens to beneficiary
        emit ERC20Released(token, releasable);
        IERC20(token).transfer(beneficiary, releasable);
    }

    /**
     * @dev Calculate the amount released according to the linear release formula. Developers can customize the release method by modifying this function.
     * @param token: token address
     * @param timestamp: query timestamp
     */
    function vestedAmount(address token, uint256 timestamp) public view returns (uint256)
    {
        // How many tokens have been received in the contract (current balance + withdrawn)
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        // Calculate the amount released according to the linear release formula
        if (timestamp < start)
        {
            return 0;
        }
        else if (timestamp > start + duration)
        {
            return totalAllocation;
        }
        else
        {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}
