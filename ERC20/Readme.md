# ERC20

ERC20 is the token standard on Ethereum, which comes from EIP20 participated by Vitalik in November 2015.<br>
It implements the basic logic of token transfer:<br>
- Account balance (*balanceOf()*)<br>
- Transfer (*transfer()*)<br>
- Authorize transfer (*transferFrom()*)
- Authorization (*approve()*)
- Total supply of tokens (*totalSupply()*)
- Authorized transfer amount (*allowance()*)
- Token information (optional): name (*name()*), symbol (*symbol()*), decimals (*decimals()*)

## IERC20

IERC20 is the interface contract of the ERC20 token standard, which specifies the functions and events that the ERC20 token needs to implement. The reason why the interface needs to be defined is that after the specification,
there will be function names, input parameters, and output parameters that are common to all ERC20 tokens. In the interface function, you only need to define the function name, input parameters, and output parameters,
and you don’t care about how the function is implemented inside.<br>
Therefore, the function is divided into two parts: internal and external. One focuses on implementation, and the other is the external interface and the agreed common data. This is why two files, ERC20.sol and IERC20.sol, are needed to implement a contract.

## Event

IERC20 defines two events: Transfer event and Approval event, which are released when transferring and authorizing respectively.
```
/**
 * @dev Release condition: when the currency of `value` unit is transferred from an account (`from`) to another account (`to`).
 */
event Transfer(address indexed from, address indexed to, uint256 value);

/**
 * @dev Release condition: when the currency of `value` unit is approved from an account (`owner`) to another account (`spender`).
 */
event Approval(address indexed owner, address indexed spender, uint256 value);
```

## Function

IERC20 defines 6 functions that provide basic functionality for transferring tokens and allow tokens to be approved for use by other third parties on the chain.

- ***totalSupply()***: returns the total supply of tokens.
```
/**
 * @dev Returns the total supply of tokens.
 */
function totalSupply() external view returns (uint256);
```

- ***balanceOf()***: returns the account balance
```
/**
 * @dev Returns the number of tokens held by account `account`.
 */
function balanceOf(address account) external view returns (uint256);
```

- ***transfer()***
```
/**
 * @dev Transfer `amount` units of tokens from the caller's account to another account `to`.
 * If successful, returns `true`.
 * Emit {Transfer} event.
 */
function transfer(address to, uint256 amount) external returns (bool);
```

- ***allowance()***: returns the authorization amount
```
/**
 * @dev Returns the amount of money that the `owner` account authorizes to the `spender` account, the default value is 0.
 * `allowance` will change when {approve} or {transferFrom} is called.
 */
function allowance(address owner, address spender) external view returns (uint256);
```

- ***approve()***: authorization
```
/**
 * @dev The caller account authorizes `amount` number of tokens to the `spender` account.
 * If successful, returns `true`.
 * Releases the {Approval} event.
 */
function approve(address spender, uint256 amount) external returns (bool);
```

- ***transferFrom()***: authorizes transfer
```
/**
 * @dev Transfer `amount` tokens from the `from` account to the `to` account through the authorization mechanism.
 * The transferred portion will be deducted from the caller's `allowance`.
 * If successful, return `true`.
 * Release the {Transfer} event.
 */
function transferFrom(address from, address to, uint256 amount) external returns (bool);
```
<hr>

# Issuing ERC20 tokens

Issue ERC20 tokens Compile the ERC20 contract on Remix, enter the constructor parameters in the deployment column, set name_ and symbol_ to \"Rich\" and \"RC\" respectively, and then click the transact button to deploy.
![deployERC20](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC20/img/deployERC20.png)

You can click the Debug button on the right to view the logs below, it contains four key information:<br>
- Event: **Transfer**
- Minting address: 0x0000000000000000000000000000000000000000
- Receiving address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
- Token amount: 100
![Mint100Tokens](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC20/img/mint100Tokens.png)

Use the balanceOf() function to query the account balance. Enter our current account and you can see that the balance becomes 100, indicating that the minting is successful.
![balanceOfAccount](https://github.com/wls503pl/Ether_Evolution_/blob/ee/ERC20/img/balanceOfAccount.png)
