// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Example of selector conflict
contract Foo
{
    bytes4 public selector1 = bytes4(keccak256("burn(uint256)"));
    bytes4 public selector2 = bytes4(keccak256("collate_propagate_storage(bytes16)"));

    // After removing the comment, the contract will not compile because two functions have the same selector
    // function burn(uint256) external {}
    // function collate_propagate_storage(bytes16) external {}
}

contract TransparentProxy
{
    address implementation;     // logic contract's address
    address admin;              // administrator
    string public words;        // Strings, it could be changed by logic contract

    // constructor, initialize admin and logic contract's address
    constructor(address _implementation)
    {
        admin = msg.sender;
        implementation = _implementation;
    }

    // fallback function, delegate the call to logic contract
    // can't be called by admin, avoid selector conflicts that cause surprises
    fallback() external payable
    {
        require(msg.sender != admin);
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // Upgrade function, change address of logic contract, could only be called by admin
    function upgrade(address newImplementation) external
    {
        if (msg.sender != admin) revert();
        implementation = newImplementation;
    }
}

// Old logic contract
contract Logic1
{
    // Status variables are the same with Proxy contract, preventing slot conflicts
    address public implementation;
    address public admin;
    string public words;        // Strings, it could be changed by Logic contract's function

    // Change status variables in Proxy contract, selector: 0xc2985578
    function foo() public
    {
        words = "old";
    }
}

// New Logic contract
contract Logic2
{
    // Status variables are the same with Proxy contract, preventing slot conflicts
    address public implementation;
    address public admin;
    string public words;        // Strings, it could be changed by Logic contract's function

    // Change status variables in Proxy contract, selector: 0xc2985578
    function foo() public
    {
        words = "new";
    } 
}
