// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/*
 * @dev An interface for the ERC20 Permit extension, allowing approval via signature, as defined in https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 * Added a {permit} method that can change an account's ERC20 balance via a message signed by the account (see {IERC20-allowance}).
 * By not relying on {IERC20-approve}, token holders' accounts do not need to send transactions, and therefore do not need to hold Ether at all.
 */
interface IERC20Permit
{
    /*
     * @dev authorizes the ERC20 balance of `owenr` to `spender` based on the signature of the owner, with the amount of `value`
     * trigger {Approval} Event.
     * requirement:
     * - 'spender' should not be address 0.
     * - 'deadline' must be a timestamp in the future
     * - `v`, `r`, and `s` must be valid `secp256k1` signatures of `owner`'s function arguments in EIP712 format.
     * - The signature MUST use the `owner`'s current nonce (see {nonces}).
     *
     * For more information on signature formats , see https://eips.ethereum.org/EIPS/eip-2612#specification.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce of `owner`. This value must be included every time a signature is generated for {permit}.
     * Each successful call to {permit} will increase the nonce of `owner` by 1. This prevents multiple use of a signature.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used to encode the signature of {permit}, as defined in {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
