# Account Splitting

Account splitting means dividing money according to a certain ratio. In reality, there are often cases of "unequal distribution of spoils"; in the world of blockchain, Code is Law, we can write the proportion that each person should share in the smart contract in advance,
and then the smart contract will divide the accounts after the income is obtained.

## Account-sharing contract

PaymentSplit has the following features:<br>
1. When creating the contract, determine the payees and each person’s shares;<br>
2. The shares can be equal or in any other proportion;<br>
3. Of all the ETH received by this contract, each beneficiary will be able to withdraw an amount proportional to their allocated share.<br>
4. The split-account contract follows the \"Pull Payment\" model. Payments are not automatically transferred to the account, but are saved in this contract. The beneficiary triggers the actual transfer by calling the *release()* function.
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * Account-sharing contract
 * @dev This contract will distribute the received ETH to several accounts according to the predetermined shares.
 * The received ETH will be stored in the split-account contract, and each beneficiary needs to call the release() function to receive it.
 */
contract PaymentSplit {
  /**
   * There are 3 events in the split-account contract:
   * PayeeAdded: The event of adding a beneficiary.
   * PaymentReleased: beneficiary withdrawal event.
   */
  event PayeeAdded(address account, uint256 shares);    // Add beneficiary event
  event PaymentReleased(address to, uint256 amount);    // Beneficiary withdrawal event
  event PaymentReceived(address from, uint256 amount);  // Contract payment event
```

## State variables

There are 5 state variables in the split-account contract, which are used to record variables such as the beneficiary address, share, and ETH paid out:
- **totalShares**: total shares, which is the sum of shares.<br>
- **totalReleased**: The ETH paid from the ledger contract to the beneficiary, which is the sum of released.<br>
- **payees**: address array, recording the beneficiary address.<br>
- **shares**: a mapping from address to uint256, recording the share of each beneficiary.<br>
- **released**: A mapping from address to uint256, recording the amount paid by the ledger contract to each beneficiary.<br>
```
uint256 public totalShares;      // Total share
uint256 public totalReleased;    // Total Payment

mapping(address => uint256) public shares;    // Each beneficiary's share
mapping(address => uint256) public released;  // Amount paid to each beneficiary
address[] public payees;        // Beneficiary array
```

## function

There are 6 functions in the split-account contract:<br>
- **Constructor**: Initialize the beneficiary array _payees and the share array _shares. The length of the array cannot be 0 and the lengths of the two arrays must be equal.
  The elements in _shares must be greater than 0, and the address in _payees cannot be 0 and there cannot be duplicate addresses.<br>
- **receive()**: Callback function, releases the PaymentReceived event when the sub-account contract receives ETH.<br>
- **release()**: The account splitting function allocates the corresponding ETH to the valid beneficiary address _account. Anyone can trigger this function, but the ETH will be transferred to the beneficiary address account.
  The releasable() function is called.<br>
- **releasable()**: Calculate the ETH that a beneficiary address should receive. Call pendingPayment() function.<br>
- **pendingPayment()**: Calculate the ETH that the beneficiary should get now based on the beneficiary's address_account, the total income of the split contract_totalReceived and the money already released by the address_alreadyReleased.<br>
- **_addPayee()**: Added new beneficiary function and its share function. They are called when the contract is initialized and cannot be modified afterwards.
