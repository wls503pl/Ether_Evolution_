// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Timelock
{
    // Event

    // Transaction cancellation event
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);

    // Transaction execution event
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);

    // Transaction created and queued event
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);

    // Event to modify the administrator address
    event NewAdmin(address indexed newAdmin);

    // Status Variables
    address public admin;                                   // Administrator Address
    uint public constant GRACE_PERIOD = 7 days;             // Transaction validity period, expired transactions will be invalidated
    uint public delay;                                      // Transaction lock time (In Seconds)
    mapping(bytes32 => bool) public queuedTransactions;     // txHash to bool, record all transactions in the time lock queue

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

    /**
     * @dev constructor, initialize transaction lock time (seconds) and administrator address
     */
    constructor(uint delay_)
    {
        delay = delay_;
        admin = msg.sender;
    }

    /**
     * @dev Change the administrator address, the caller must be the Timelock contract.
     */
    function changeAdmin(address newAdmin) public onlyTimelock
    {
        admin = newAdmin;

        emit NewAdmin(newAdmin);
    }

    /**
     * @dev creates a transaction and adds it to the time lock queue.
     * @param target: target contract address
     * @param value: send eth amount
     * @param signature: function signature to be called
     * @param data: call data, which contains some parameters
     * @param executeTime: blockchain timestamp of transaction execution
     *
     * Requirement: executeTime is greater than the current blockchain timestamp + delay
     */
    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime)
    public onlyOwner returns (bytes32)
    {
        // Check: transaction execution time meets lock time
        require(executeTime >= getBlockTimestamp() + delay, "Timelock::queueTransaction: Estimated execution block must satisfy delay.");

        // Calculating a unique identifier for a transaction: a hash of a parameters
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);

        // Add the transaction to the queue
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    /**
     * @dev Cancel a specific transaction.
     * Requirement: transaction is in the timelock queue
     */
    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner
    {
        // Calculate the unique identifier of the transaction: hash of a bunch of stuff
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);

        // Check: transaction is in timelock queue
        require(queuedTransactions[txHash], "Timelock::cancelTransaction: Transaction hasn't been queued.");

        // Remove the transaction from the queue
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }

    /**
     * @dev Execute a specific transaction.
     * Requirements:
     * 1. The transaction is in the time lock queue
     * 2. The transaction execution time is reached
     * 3. The transaction has not expired
     */
    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime)
    public payable onlyOwner returns (bytes memory)
    {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);

        // Check: Is the transaction in the time lock queue?
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");

        // Check: transaction execution time reached
        require(getBlockTimestamp() >= executeTime, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");

        // Check: transaction has not expired
        require(getBlockTimestamp() <= executeTime + GRACE_PERIOD, "Timelock::executeTransaction: Transaction is stale.");

        // Remove the transaction from the queue
        queuedTransactions[txHash] = false;

        // Acquire call data
        bytes memory callData;

        if (bytes(signature).length == 0)
        {
            callData = data;
        }
        else
        {
            // If you use "encodeWithSignature" to call the administrator function, please change the parameter data type to address. Otherwise,
            // the administrator value will become something like "0x0000000000000000000000000000000000000000020". 0x20 means the length of the byte array.
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // Use call to execute the transaction
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);

        return returnData;
    }

    /**
     * @dev Get the current blockchain timestamp
     */
    function getBlockTimestamp() public view returns (uint)
    {
        return block.timestamp;
    }

    /**
     * @dev combines a bunch of function parameters into a transaction identifier
     */
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32)
    {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }
}