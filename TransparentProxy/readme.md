## Selector Conflict

In smart contracts, the function selector is the first 4 bytes of the hash of the function signature. For example, the selector of **mint(address account)** is **bytes4(keccak256("mint(address)"))**,
which is **0x6a627842**.<br>
Since the function selector is only 4 bytes and has a small range, two different functions may have the same selector, such as the following two functions:
```
// Selector conflict example
contract Foo
{
  function burn(uint256) external {}
  function collate_propagate_storage(bytes16) external {}
}
```

![selector1_2](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TransparentProxy/img/selector1_2.png)<br><br>

In this example, the selectors of the functions burn() and collate_propagate_storage() are both 0x42966c68, which is the same. This situation is called a "selector conflict".
In this case, the EVM cannot tell which function the user is calling by the function selector, so the contract cannot be compiled.

Since the proxy contract and the logic contract are two contracts, they can be compiled normally even if there is a "selector conflict" between them, which may lead to serious security incidents.
For example, if the selector of the logic contract's a function and the proxy contract's upgrade function are the same, then the manager will upgrade the proxy contract to a black hole contract
when calling the a function, and the consequences will be disastrous.

Currently, there are two upgradeable contract standards to solve this problem: **Transparent Proxy** and Universal Upgradeable Proxy **UUPS**.

## Transparent Proxy

The logic of transparent proxy is very simple: the administrator may mistakenly call the upgradeable function of the proxy contract when calling the function of the logic contract due to "function selector conflict".
Then restricting the administrator's authority and not allowing him to call any function of the logic contract can solve the conflict:
- The administrator becomes a tool person and can only call the upgradeable function of the proxy contract to upgrade the contract, and cannot call the logic contract through the callback function.
- Other users cannot call upgradeable functions, but can call functions of the logic contract.

## Proxy Contract

The *fallback()* function restricts the calling of the administrator address.
It contains 3 variables:
- implementation: logical contract address.
- admin: admin address.
- words: Strings, it could be changed by Logic Contract's function.

It contains 3 function:
- ***Constructor***: Initialize admin and logical contract address.
- ***fallback()***: callback function that delegates the call to the logic contract and cannot be called by the admin.
- ***upgrade()***: Upgrade function, change the logical contract address, can only be called by admin.

## Logic Contract

The logic contract contains 3 state variables, which are consistent with the proxy contract to prevent slot conflicts; it contains a function foo(), the old logic contract will change the value of words to "old",
and the new one will change it to "new".

<hr>

# Remix Demo

- **Step 1**:

  After deploy logic contract **\"Logic1\"** and **\"Logic2\"**, deploy the transparent proxy contract **TranparentProxy** and point the **implementation** address to the old logic contract.
  <br><br>
  ![deployTransparentProxy](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TransparentProxy/img/deployTransparentProxy.png)<br><br>
  
- **Step 2**:

  Using selector **0xc2985578**, call the *foo()* function of the old logic contract **\"Logic1\"** in the **Proxy** contract. The call will fail because the administrator cannot call the logic contract.
  <br><br>
  ![Logic1_foo_failed](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TransparentProxy/img/Logic1_foo_failed.png)<br><br>
  
- **Step 3**:

Switch to the new wallet, use the selector **0xc2985578**, call the *foo()* function of the old logic contract **\"Logic1\"** in the Proxy contract, change the value of words to \"old\", and tihs call will succeed.
<br><br>
![Logic1_foo_succeed](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TransparentProxy/img/Logic1_foo_succeed.png)<br><br>

- **Step 4**:

Switch back to the administrator wallet, call upgrade(), and point the implementation address to the new logic contract Logic2.
<br><br>
![upgrade](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TransparentProxy/img/upgrade.png)<br><br>

- **Step 5**:

Switch to a new wallet, use the selector **0xc2985578**, call the *foo()* function of the new logic contract **\"Logic2\"** in the proxy contract, and change the value of words to **\"new\"**.
<br><br>
![Logic2_foo](https://github.com/wls503pl/Ether_Evolution_/blob/ee/TransparentProxy/img/Logic2_foo.png)<br><br>
