// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

/**
 * @dev ERC20 interface contract.
 */
interface IERC20 {
    /**
     * @dev Release condition: when the currency of `value` unit is transferred from an account (`from`) to another account (`to`).
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Release condition: when the currency of `value` unit is authorized from an account (`owner`) to another account (`spender`).
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev returns the total token supply.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev returns the total token supply.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Transfer `amount` units of tokens from the caller's account to another account `to`.
     * If successful, returns `true`.
     * Emit {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev returns the amount of money that the `owner` account authorizes to the `spender` account, the default is 0.
     *
     * `allowance` will change when {approve} or {transferFrom} is called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev The caller account authorizes `amount` number of tokens to the `spender` account.
     * If successful, returns `true`.
     * Releases the {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Transfer `amount` tokens from the `from` account to the `to` account through the authorization mechanism.
     * The transferred portion will be deducted from the caller's `allowance`.
     * If successful, return `true`.
     * Release the {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}