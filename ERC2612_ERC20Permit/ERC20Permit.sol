// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/*
 * @dev An interface for the ERC20 Permit extension, allowing approval via signature, as defined in https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 * Added a {permit} method that can change an account's ERC20 balance via a message signed by the account (see {IERC20-allowance}). By not relying on {IERC20-approve},
 * token holders' accounts do not need to send transactions, and therefore do not need to hold Ether at all.
 */
contract ERC20Permit is ERC20, IERC20Permit, EIP712
{
    mapping(address => uint) private _nonces;
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    
    // @dev initializes the EIP712 name and ERC20 name and symbol
    constructor(string memory name, string memory symbol) EIP712(name, "1") ERC20(name, symbol) {}

    // @dev See {IERC20Permit-permit}
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override
    {
        // check deadline
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        // Hash concatenation
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));
        bytes32 hash = _hashTypedDataV4(structHash);

        // Calculate signer from signature and message, and verify signature
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        // Authorization
        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner];
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "consume nonce": returns the current `nonce` of `owner` and increases it by 1.
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        current = _nonces[owner];
        _nonces[owner] += 1;
    }

    // @dev mint tokens
    function mint(uint amount) external {
        _mint(msg.sender, amount);
    }
}
