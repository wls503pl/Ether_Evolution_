# Multicall

In Solidity, the design of MultiCall contract allows us to execute multiple function calls in one transaction. Its advantages are as follows:
1. **Convenience**: MultiCall allows you to call different functions of different contracts in one transaction, and these calls can also use different parameters. For example, you can query the ERC20 token balances of multiple addresses at one time.
2. **Save gas**: MultiCall can combine multiple transactions into multiple calls in one transaction, thus saving gas.
3. **Atomicity**: MultiCall allows users to perform all operations in one transaction, ensuring that all operations are either all successful or all failed, thus maintaining atomicity. For example, you can perform a series of token transactions in a specific order.

## MultiCall Contract

The MultiCall contract defines two structures:
- **Call**: This is a call structure, which contains the target contract to be called, the flag allowFailure indicating whether the call is allowed to fail, and the bytecode call data to be called.
- **Result**: This is a result structure, which contains the success flag indicating whether the call is successful and the bytecode return data returned by the call.

The contract contains only one function, which is used to perform multiple calls:
- ***multicall()***: The parameter of this function is an array of Call structures, which ensures that the length of the target and data passed in are consistent. The function executes multiple calls through a loop and rolls back the transaction if the call fails.

<hr>

# Remix Reproduction

- **Step1**: Deploy a very simple ERC20 token contract MCERC20 and record the contract address.
![]()<br><br>

- **Step2**: Deploy **MultiCall** contract.
![]()<br><br>

- **Step3**: Get the calldata to be called. We will mint 50 and 100 units of tokens to two addresses respectively. Fill in the parameters of ***mint()*** on the call page of remix, and then click the Calldata button to copy the encoded calldata.<br>
  Example:
  ```
  to: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
  amount: 50
  calldata: 0x40c10f190000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000032
  ```
  
