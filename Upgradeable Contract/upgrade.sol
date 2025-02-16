// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract SimpleUpgrade
{
    address public implementation;  // Logic contract's address
    address public admin;           // admin address
    string public words;            // Strings, it could be changed by Logic contract's function

    // Constructor, initialize admin and Logic contract's address
    constructor(address _implementation)
    {
        admin = msg.sender;
        implementation = _implementation;
    }

    // fallback function, it delegate the call to the Logic contract
    fallback() external payable
    {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // upgrade function, change Logic contract's address, could only be called by admin
    function upgrade(address newImplementation) external
    {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}

// Logic contract 1
contract Logic1
{
    // Status variable is the same with Proxy contract's, preventing slot conflicts
    address public implementation;
    address public admin;
    string public words;    // String, it could be changed by Logic contract's function

    // Change Proxy contract's status variable, selector: 0x2985578
    function foo() public
    {
        words = "old";
    }
}

// Logic contract 2
contract Logic2
{
    // Status variable is the same with Proxy contract's, preventing slot conflicts
    address public implementation;
    address public admin;
    string public words;    // String, it could be changed by Logic contract's function

    // Change Proxy contract's status variable, selector: 0x2985578
    function foo() public
    {
        words = "new";
    }
}
