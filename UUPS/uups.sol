// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * UUPS's Proxy is the same like normal Proxy.
 * Upgrade function in the logic contract, administrator can change the logic contract's address through the upgrade function,
 * thereby changing the logic of the contract.
 */
contract UUPSProxy
{
    address public implementation;  // logic contract's address
    address public admin;           // admin address
    string public words;            // Strings, it could be changed by logic contract's function

    // constructor, init admin and Logic Contract's address
    constructor(address _implementation)
    {
        admin = msg.sender;
        implementation = _implementation;
    }

    // fallback() function, delegate the call to the Logic contract
    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
}

// UUPS logic contract (upgrade function is written in the logic contract)
contract UUPS1
{
    // Status variable is the same with Proxy Contract's, preventing slot conflicts
    address public implementation;
    address public admin;
    string public words;        // Strings, it could be changed by Logic contract's function

    // Change Proxy's status variable, Selector: 0xc2985578
    function foo() public
    {
        words = "old";
    }

    // upgrade function, change Logic contract's address, could only be called by admin, selector: 0x0900f010
    function upgrade(address newImplementation) external
    {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}

// new UUPS Logic contract
contract UUPS2
{
    // Status variable is the same like Proxy Contract's, Preventing slot conflicts
    address public implementation;
    address public admin;
    string public words;        // String, it could be changed by Logic Contract's function

    // change status variable in Proxy contract, selector: 0xc2985578
    function foo() public
    {
        words = "new";
    }

    // Upgrade function, change the logical contract address, can only be called by admin. Selector: 0x0900f010
    // In UUPS, the logic function must include the upgrade function, otherwise it cannot be upgraded.
    function upgrade(address newImplementation) external
    {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}
