// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * Account splitting contract
 * @dev This contract will distribute the received ETH to several accounts according to the predetermined shares.
 * The received ETH will be stored in the account splitting contract, and each beneficiary needs to call the release() function to receive it.
 */
contract PaymentSplit
{
    // Event
    event PayeeAdded(address account, uint256 shares);          // Add beneficiary event
    event PaymentReleased(address to, uint256 amount);          // Beneficiary withdrawal event
    event PaymentReceived(address from, uint256 amount);        //Contract payment event

    uint256 public totalShares;             // total shares
    uint256 public totalReleased;           // Total Payment

    mapping(address => uint256) public shares;          // Shares of each beneficiary
    mapping(address => uint256) public released;        // Amount paid to each beneficiary
    address[] public payees;                // beneficiary array

    /**
     * @dev Initialize the beneficiary array _payees and the share array _shares
     * The array length cannot be 0, and the two array lengths must be equal. The elements in _shares must be greater than 0,
     * and the address in _payees cannot be 0 and there cannot be duplicate addresses
     */
    constructor(address[] memory _payees, uint256[] memory _shares) payable 
    {
        // Check that the _payees and _shares arrays have the same length and are not 0
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");

        // Call _addPayee to update the beneficiary address payees, beneficiary share shares and total share totalShares
        for (uint256 i = 0; i < _payees.length; i++)
        {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    /**
     * @dev callback function, receiving ETH release PaymentReceived event
     */
    receive() external payable virtual
    {
        emit PaymentReceived(msg.sender, msg.value);
    }
    
    /**
     * @dev splits the account for the valid beneficiary address _account, and the corresponding ETH is sent directly to the beneficiary address.
     * Anyone can trigger this function, but the money will be transferred to the account address.
     * The releasable() function is called.
     */
    function release(address payable _account) public virtual
    {
        // account must be a valid beneficiary
        require(shares[_account] > 0, "PaymentSplitter: account has no shares");

        // Calculate the eth that the account deserves
        uint256 payment = releasable(_account);

        // The eth you deserve cannot be 0
        require(payment != 0, "PaymentSplitter: account is not due payment");

        // Update the total payment totalReleased and the amount paid to each beneficiary released
        totalReleased += payment;
        released[_account] += payment;

        // transfer
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }

    /**
     * @dev Calculates the eth that an account can receive.
     * Calls pendingPayment() function.
     */
    function releasable(address _account) public view returns (uint256)
    {
        // Calculate the total revenue of the split contract totalReceived
        uint256 totalReceived = address(this).balance + totalReleased;

        // Call _pendingPayment to calculate the ETH that the account deserves
        return pendingPayment(_account, totalReceived, released[_account]);
    }

    /**
     * @dev Calculate the current amount of `ETH` that the beneficiary should receive based on the beneficiary's address `_account`,
     * the total income of the split contract `_totalReceived`, and the money already received by the address `_alreadyReleased`.
     */
    function pendingPayment(
        address _account,
        uint256 _totalReceived,
        uint256 _alreadyReleased
    ) public view returns (uint256) {
        // ETH that the account deserves = Total ETH that the account deserves - ETH that has been received
        return _totalReceived * (shares[_account] / totalShares) - _alreadyReleased;
    }

    /**
     * @dev Add the beneficiary_account and the corresponding share_accountShares. It can only be called in the constructor and cannot be modified.
     */
    function _addPayee(address _account, uint256 _accountShares) private
    {
        // Check if _account is not 0 address
        require(_account != address(0), "PaymentSplitter: account is the zero address");

        // Check that _accountShares is not 0
        require(_accountShares > 0, "PaymentSplitter: shares are 0");

        // Check if _account is not duplicated
        require(shares[_account] == 0, "PaymentSplitter: account already has shares");

        // Update payees, shares and totalShares
        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;

        // Release the event of adding beneficiaries
        emit PayeeAdded(_account, _accountShares);
    }
}