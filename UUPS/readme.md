# UUPS

It's fullname is **\"universal upgradeable proxy standard\"**.

## Selector Clash

If there are two functions with the same selector in a contract, serious consequences may occur. As an alternative to transparent proxy, UUPS can also solve this problem.<br>
UUPS (universal upgradeable proxy standard) puts the upgrade function in the logic contract. In this way, if there is a "selector conflict" between other functions and the upgrade function,
an error will be reported during compilation.<br>

The following table summarizes the differences between normal upgradeable contracts, transparent proxies, and UUPS:
<br>
![upgradeContractDifference](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/upgradeContractDifference.png)<br><br>

As shown in the figure below, if user A delegatecalls contract C (logic contract) through contract B (proxy contract), the context is still the context of contract B,
and msg.sender is still user A instead of contract B. Therefore, the UUPS contract can put the upgrade function in the logical contract and check whether the caller is an administrator.
<br>
![ABCDelegateCall](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/ABCDelegateCall.png)<br><br>

## UUPS Proxy Contract

The UUPS proxy contract looks like a non-upgradeable proxy contract, which is very simple because the upgrade function is placed in the logic contract.<br>
It contains 3 variables:
- **implementation**: logical contract address.
- **admin**: admin address.
- **words**: string, which can be changed by the function of the logic contract.

It contains 2 functions:
- **Constructor**: Initialize admin and logical contract address.
- **fallback()**: Callback function that delegates the call to the logic contract.

## UUPS Logical Contract

The logical contract of UUPS is different from the previous contract in that it has an additional upgrade function,
The UUPS logic contract contains 3 state variables, which are consistent with the proxy contract to prevent slot conflicts. It contains 2 functions.<br>
- ***upgrade()***: Upgrade function, which will change the logical contract address implementation and can only be called by admin.
- ***foo()***: The old UUPS logic contract will change the value of words to **\"old\"**, and the new one will change it to **\"new\"**.

<hr>

# Remix Demo

- **Step1**:
  Deploy UUPS new and old logical contracts UUPS1 and UUPS2.
  <br><br>
  ![DeployUUPS1_2](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/DeployUUPS1_2.png)<br><br>

- **Step2**:
  Deploy the UUPS proxy contract UUPSProxy and point the implementation address to the old logical contract UUPS1.
  <br><br>
  ![DeployUUPSProxy](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/DeployUUPSProxy.png)<br><br>

- **Step3**:
  Using selector **0xc2985578**, call the *foo()* function of the old logic contract **UUPS1** in the proxy contract and change the value of words to \"old\".
  <br><br>
  ![UUPS1_foo](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/UUPS1_foo.png)<br><br>

- **Step4**:
  Use the online ABI encoder [HashEx](https://abi.hashex.org/)
  to obtain the binary code, call the upgrade function upgrade(), and point the implementation address to the new logical contract UUPS2.
  <br><br>
  ![HashEx](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/HashEx.png)
  ![ChangeLogicContractAddress](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/ChangeLogicContractAddress.png)<br><br>

- **Step5**:
  Using the selector **0xc2985578**, call the *foo()* function of the new logic contract **UUPS2** in the Proxy contract and change the value of words to \"new\".
  <br><br>
  ![wordsChanged](https://github.com/wls503pl/Ether_Evolution_/blob/ee/UUPS/img/wordsChanged.png)<br>

## Summarize

Introduced another solution to the "selector conflict" of the proxy contract: UUPS. Unlike transparent proxy, UUPS puts the upgrade function in the logic contract, so that the "selector conflict" cannot be compiled. Compared with transparent proxy, UUPS saves more gas, but is also more complicated.
