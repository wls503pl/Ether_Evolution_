# Timelock

**Timelock**, A common locking mechanism found in bank vaults and other high-security containers. It is a timer designed to prevent the safe or vault from being opened before a preset time,
even if the person who opens the lock knows the correct combination.<br>
In blockchain, time locks are widely used by DeFi and DAO. It is a piece of code that can lock certain functions of smart contracts for a period of time. It can greatly improve the security of smart contracts.<br>

For example, if a hacker hacks Uniswap's multi-signature and plans to withdraw the money from the vault, but the vault contract adds a 2-day lock period,
then the hacker needs a 2-day waiting period from creating the withdrawal transaction to actually withdrawing the money. During this period, the project side can find a solution,
and investors can sell tokens in advance to reduce losses.

## Timelock Contract

Its logic is not complicated:<br>
- When creating a Timelock contract, the project owner can set the lock-up period and set the administrator of the contract to himself.
- Time lock has 3 main functionalities:
    - Create a transaction and add it to the time lock queue.
    - After the lock period of the transaction expires, execute the transaction.
    - Regret, cancel some transactions in the time lock queue.
- Project owners usually set time-lock contracts as administrators of important contracts, such as vault contracts, and then operate them through time locks.
- The administrator of the time lock contract is generally the multi-signature wallet of the project to ensure decentralization.

## Event

There are 4 events in the Timelock contract.
- **QueueTransaction**: Event in which a transaction is created and enters the time lock queue.
- **ExecuteTransaction**: Event for transaction execution after the lock period expires.
- **CancelTransaction**: transaction cancellation event.
- **NewAdmin**: event for modifying the administrator address.
```
// Event

// Transaction created and entered into queue event
event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);

// Transaction execution event
event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);

// Transaction cancellation event
event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);

// Event to modify the administrator address
event NewAdmin(address indexed newAdmin);
```

## Status Variables

There are 4 state variables in the Timelock contract:
- **admin**: Administrator address
- **delay**: lock-up period
- **GRACE_PERIOD**: Transaction expiration time. If a transaction reaches the execution time point but is not executed within GRACE_PERIOD, it will expire.
- **queuedTransactions**: A mapping from the identifier txHash of the transaction entering the time lock queue to bool, recording all transactions in the time lock queue.
```
// Status Variables
address public admin;                                     // Administrator's address
uint public constant GRACE_PERIOD = 7 days;               // Transaction validity period, expired transactions will be invalidated
uint public delay;                                        // Transaction lock time (seconds)
mapping (bytes32 => bool) public queuedTransactions;      // txHash to bool, record all transactions in the time lock queue
```

## Decorators

There are 2 modifiers in the Timelock contract:<br>
- **onlyOwner()**: The modified function can only be executed by the administrator.
- **onlyTimelock()**: The modified function can only be executed by the timelock contract.
```
// onlyOwner modifier
modifier onlyOwner()
{
  require(msg.sender == admin, "Timelock: Caller not admin");
  _;
}

// onlyTimelock modifier
modifier onlyTimelock()
{
  require(msg.sender == address(this), "Timelock: Caller not Timelock");
  _;
}
```

## Function

There are 7 functions in the Timelock contract:
- ***constructor()***: Initialize transaction lock time (seconds) and administrator address.
- ***queueTransaction()***: Creates a transaction and adds it to the time lock queue. The parameters are more complicated because they describe a complete transaction:
    - **target**: target contract address
    - **value**: Send ETH amount
    - **signature**: The function signature to be called
    - **data**: Transaction call data
    - **executeTime**: Blockchain timestamp of transaction execution
  When calling this function, ensure that the estimated execution time of the transaction executeTime is greater than the current blockchain timestamp + lock time delay.
  The unique identifier of the transaction is the hash value of all parameters, calculated using the getTxHash() function.
  Transactions entering the queue will be updated in the queuedTransactions variable and the QueueTransaction event will be released.

- ***executeTransaction()***: Execute a transaction. Its parameters are the same as *queueTransaction()*. It requires that the transaction to be executed is in the time-locked queue,
  reaches the transaction execution time, and has not expired. The low-level member function call of solidity is used when executing transactions.

- ***cancelTransaction()***: Cancels a transaction. Its parameters are the same as queueTransaction(). It requires the transaction to be canceled to be in the queue, updates queuedTransactions and releases the CancelTransaction event.
- ***changeAdmin()***: Modify the administrator address, which can only be called by the Timelock contract.
- ***getBlockTimestamp()***: Get the current blockchain timestamp.
- ***getTxHash()***: Returns the transaction identifier, which is a hash of many transaction parameters.

<hr>

# Remix Demo

- **Step1**: Deploy the Timelock contract, and set the lock period to 120 seconds.
![deployTimeLock](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Timelock/img/deployTimeLock.png)

- **Step2**: Calling *changeAdmin()* directly will result in an error。
![changeAdminError](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Timelock/img/changeAdminError.png)

- **Step3**: Constructing a transaction to change the administrator.
  To construct a transaction, we need to fill in the following parameters: **address target**, **uint256 value**, **string memory signature**, **bytes memory data**, **uint256 executeTime**.
    - **target**: Because the function called is Timelock's own function, fill in the contract address.
    - **value**: No need to transfer ETH, fill in 0 here.
    - **signature**: The function signature of *changeAdmin()* is: \"changeAdmin(address)\".
    - **Data**: Fill in the parameters to be passed in, that is, the address of the new administrator. However, the address must be filled with 32 bytes of data to meet the Ethereum ABI encoding standard. You can use the hashex website to encode the parameters in ABI. Example:
```
    Address before encoding: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    Encoded address: 0x0000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb2
```
- **executeTime**: first call getBlockTimestamp() to get the current blockchain time, then add 139(> 120) seconds to it.
  ![queueTransaction](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Timelock/img/queueTransaction.png)

- **Step4**: The executeTransaction method failed when it was called during the lock period.
![executeTransactionFailed](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Timelock/img/executeTransactionFailed.png)

- **Step5**: Call executeTransaction when the lock period expires, and the transaction succeeds, Check out the new admin address. It has been changed.
![execTransactionSuccessful](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Timelock/img/execTransactionSuccessful.png)

