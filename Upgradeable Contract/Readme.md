# Upgradable contracts

If you understand the proxy contract, it is easy to understand the upgradeable contract. It is a proxy contract that can change the logic contract.
<br><br><br>
![Upgradable Contract](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Upgradeable%20Contract/img/LogicOfUpgradableContract.png)

## Simple Implementation

It contains 3 contracts: proxy contract, old logic contract, and new logic contract.

## Proxy Contract

We did not use inline assembly in its fallback() function, but only used implementation.delegatecall(msg.data). Therefore, the callback function has no return value.

It contains 3 variables:
- **implementation**: logical contract address.
- **admin**: admin address.
- **words**: string, which can be changed by the function of the logic contract.

It contains 3 functions:
- ***Constructor***: Initialize **implementation** and **admin**.
- ***fallback()***: Callback function, delegating the call to the logic contract.
- ***upgrade()***: Upgrade function, change the logical contract address, can only be called by admin.

## Old Logic Contract

This logic contract contains 3 state variables, which are consistent with the proxy contract to prevent slot conflicts. It has only one function foo(), which changes the value of words in the proxy contract to "old".

## New Logic Contract

This logic contract contains 3 state variables, which are consistent with the proxy contract to prevent slot conflicts. It has only one function foo(), which changes the value of words in the proxy contract to "new".

<hr>

# Remix Demo

**Step1**: Deploy old logic contract **\"Logic1\"** and new logic contract **\"Logic2\"**.
<br><br>
![deployLogic1_2](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Upgradeable%20Contract/img/deployLogic1_2.png)<br>

**Step2**: Deploy the upgradeable contract **SimpleUpgrade** and point the **implementation** address to the old logic contract.

![deploySimpleUpgrade](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Upgradeable%20Contract/img/deploySimpleUpgrade.png)<br>

**Step3**: Using selector **0xc2985578**, call the *foo()* function of the old logic contract **\"Logic1\"** in the proxy contract and change the value of words to 
**\"old\"**.

![Logic1Foo](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Upgradeable%20Contract/img/Logic1Foo.png)<br>

**Step4**: Call ***upgrade()*** to point the implementation address to the new logic contract **\"Logic2\"**.

![callUpgrade](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Upgradeable%20Contract/img/callUpgrade.png)<br>

**Step5**: Using selector **0xc2985578**, call the *foo()* function of the new logic contract **\"Logic2\"** in the proxy contract and change the value of words to **\"new\"**.

![Logic2Foo](https://github.com/wls503pl/Ether_Evolution_/blob/ee/Upgradeable%20Contract/img/Logic2Foo.png)<br>

This contract has a selector conflict problem, which poses a security risk. Later we will introduce the upgradeable contract standards that solve this risk: **transparent proxy** and **UUPS**.
