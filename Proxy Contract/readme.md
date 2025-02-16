# Proxy Mode

After the Solidity contract is deployed on the chain, the code is immutable. This has both advantages and disadvantages:
- **Pros**: Safe, users know what to expect (most of the time)
- **Disadvantages**: Even if there is a bug in the contract, it cannot be modified or upgraded, and a new contract can only be deployed. However, the address of the new contract is different from the old one,
  and the contract data also needs to spend a lot of gas to migrate.

Is there a way to modify or upgrade the contract after it is deployed? The answer is yes, and that is the **proxy mode**.

![delegateContractLogic](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Proxy%20Contract/img/delegateContractLogic.png)

The proxy mode separates contract data and logic and stores them in different contracts.<br>
Take the simple proxy contract in the figure above as an example. The data (state variables) are stored in the **proxy** contract. The logic (function) is stored in another logic contract(**Implementation**)<br>
The proxy contract (**Proxy**) delegates the function call to the logic contract (**Implementation**) through *delegatecall*, and then returns the final result to the caller (**Caller**).

The proxy model has two main benefits:<br>
1. **Upgradable**: When we need to upgrade the logic of the contract, we only need to point the proxy contract to the new logic contract.<br>
2. **Save gas**: If multiple contracts reuse a set of logic, we only need to deploy one logic contract, and then deploy multiple proxy contracts that only save data and point to the logic contract.

## Proxy Contract

It has three parts: a proxy contract Proxy, a logic contract Logic, and a call example Caller. Its logic is not complicated:
- First deploy the logic contract Logic.
- Create a proxy contract Proxy, and the state variable implementation records the Logic contract address.
- The Proxy contract uses the callback function fallback to delegate all calls to the Logic contract.
- Finally, deploy and call the sample Caller contract and call the Proxy contract.
- **Note**: The state variable storage structure of the Logic contract and the Proxy contract is the same, otherwise the delegatecall will produce unexpected behavior and pose a security risk.

The Proxy contract is not long, but it uses inline assembly, so it is difficult to understand. It has only one state variable, a constructor, and a callback function.
The state variable implementation is initialized in the constructor and is used to save the Logic contract address.
```
contract Proxy
{
  // Logical contract address.
  // The state variable type of the same position in the implementation contract must be the same as that of the Proxy contract,
  // otherwise an error will be reported.
  address public implementation;

  /**
   * @dev Initialize the logical contract address
   */
  constructor(address implementation_)
  {
    implementation = implementation_;
  }
}
```
The callback function of Proxy delegates the external call to this contract to the Logic contract. This callback function is very unique.
It uses inline assembly to allow the callback function that originally cannot have a return value to have a return value. The inline assembly opcodes used are:
- ***calldatacopy(t, f, s)***: copies calldata (input data) starting at position f and s bytes to mem (memory) position t.
- ***delegatecall(g, a, in, insize, out, outsize)***: calls the contract at address a, with input mem[in..(in+insize)) and output mem[out..(out+outsize)) ,
  providing gwei of Ethereum gas. This opcode returns 0 on error and 1 on success.
- ***delegatecall(g, a, in, insize, out, outsize)***: calls the contract at address a, with input mem[in..(in+insize)) and output mem[out..(out+outsize)) ,
  providing gwei of Ethereum gas. This opcode returns 0 on error and 1 on success.
- ***returndatacopy(t, f, s)***: copies returndata (output data) starting at position f and ending at position t in mem (memory).
- ***switch***: basic \"if/else\", different cases return different values. There can be a default case.
- ***return(p, s)***: terminate function execution, return data mem[p..(p+s)).
- ***revert(p, s)***: terminate function execution, roll back state, and return data mem[p..(p+s)).

## Logic Contract

This is a very simple logic contract, just to demonstrate the proxy contract. It contains 2 variables, 1 event, and 1 function:
- **implementation**: Placeholder variable, consistent with the Proxy contract to prevent slot conflicts.
- **x**: uint variable, set to 99.
- **CallSuccess event**: released when the call is successful
- **increment() function**: It will be called by the Proxy contract, release the CallSuccess event, and return a uint, whose selector is 0xd09de08a. If increment() is called directly, it will return 100, but if it is called through the Proxy, it will return 1.

## \"Caller\" contract

The Caller contract will demonstrate how to call a proxy contract.
It has 1 variable and 2 functions:
- **proxy**: state variable, records the proxy contract address.
- **Constructor**: Initialize the proxy variable when deploying the contract.
- **increase()**: Use call to call the *increment()* function of the proxy contract and return a uint. When calling, we use *abi.encodeWithSignature()* to get the selector of the *increment()* function. When returning, use *abi.decode()* to decode the return value into a uint type.

<hr>

## Remix Demo

After deploy contract \"Logic\", check **\"x\"**, whosevalue is \"99\", call Logic's *increment()* function, it will return \"100\".
![LogicIncrement](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Proxy%20Contract/img/LogicIncrement.png)

Deploy **\"Proxy\"** contract, fill in Logic Contract's address when initialization.
![deployProxy](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Proxy%20Contract/img/deployProxy.png)

Calling method: Click the Proxy contract in the Remix deployment panel, fill in the *increment()* function selector **0xd09de08a** in the bottom Low level interaction, and click Transact.
![LowLevelInteraction](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Proxy%20Contract/img/LowLevelInteraction.png)

Deploy the Caller contract and fill in the **\"Proxy\"** contract address during initialization.
![deployProxy](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Proxy%20Contract/img/deployProxy.png)

When the Caller contract delegates the call to the Logic contract through the Proxy contract, if the Logic contract function changes or reads some state variables, it will operate on the corresponding variables of the Proxy. Here, the value of the x variable of the Proxy contract is 0 (because the x variable has never been set, that is, the corresponding position value of the storage area of ​​the Proxy contract is 0), so calling increment() through the Proxy will return **1**.
![callerIncrement](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Proxy%20Contract/img/callerIncrement.png)
