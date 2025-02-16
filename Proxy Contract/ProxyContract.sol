// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @dev All calls to the Proxy contract are delegated to another contract through the `delegatecall` opcode. 
 * The latter is called the logical contract (Implementation).
 * The return value of the delegate call will be returned directly to the caller of the Proxy
 */
contract Proxy
{
    /**
     * Logical contract address.
     * The state variable type of the same position in the implementation contract must be the same with the Proxy contract,
     * otherwise an error will be reported.
     */
    address public implementation;

    /**
     * @dev Initialize the address of Logic Contract
     */
    constructor(address implementation_)
    {
        implementation = implementation_;
    }

    /**
     * @dev callback function, call `_delegate()` function to delegate the call of this contract to `implementation` contract
     */
    fallback() external payable
    {
        _delegate();
    }

    /**
     * @dev delegates the call to the logic contract execution
     */
    function _delegate() internal
    {
        assembly
        {
            /**
             * Copy msg.data. We take full control of memory in this inline assembly block,
             * because it will not return to Solidity code. We overwrite the Read storage at position 0,
             * which is the implementation address
             */
            let _implementation := sload(0)

            calldatacopy(0, 0, calldatasize())

            /**
             * Use delegatecall to call the implementation contract.
             * The parameters of the delegatecall opcode are: "gas", "target contract address", "input mem starting position", 
             * "input mem length", "output area mem starting position", "output area mem length".
             * The output area starting position and length position, so set to 0.
             * The delegatecall returns 1 if successful and 0 if failed.
             */
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            //Copy the returndata with the starting position of 0 and the length of returndatasize() to mem position 0
            returndatacopy(0, 0, returndatasize())

            switch result
            
            // if call of delegate failed, do revert
            case 0
            {
                revert(0, returndatasize())
            }
            default
            {
                return(0, returndatasize())
            }
        }
    }
}

/**
 * @dev logical contract, executes the delegated call
 */
contract Logic
{
    // Keep consistent with Proxy to prevent slot conflicts
    address public implementation;

    uint public x = 99;
    event CallSuccess();

    // This function releases LogicCalled and returns a uint
    // Function selector: 0xd09de08a
    function increment() external returns(uint)
    {
        emit CallSuccess();    
        return x+1;
    }
}

/**
 * @dev Caller contract, call the proxy contract and get the execution result
 */
contract Caller
{
    // Proxy contract address
    address public proxy;

    constructor(address proxy_)
    {
        proxy = proxy_;
    }

    // Call the increase() function through the proxy contract
    function increase() external returns(uint)
    {
        (, bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
        return abi.decode(data, (uint));
    }
}
