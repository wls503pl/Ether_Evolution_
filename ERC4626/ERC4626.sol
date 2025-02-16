
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC4626} from "./IERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev ERC4626 "Tokenized Treasury Standard" contract, for educational purposes only,
 * do not use in production
 */
contract ERC4626 is ERC20, IERC4626 {
    // State variables
    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(
        ERC20 asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _asset = asset_;
        _decimals = asset_.decimals();

    }

    /** @dev See {IERC4626-asset}. */
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }

    /**
     * See {IERC20Metadata-decimals}.
     */
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _decimals;
    }

    // Deposit/Withdrawal Logic
    /** @dev See {IERC4626-deposit}. */
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Use previewDeposit() to calculate the share of the vault that will be obtained
        shares = previewDeposit(assets);

        // Transfer first, then mint to prevent reentry
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // Release Deposit Event
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /** @dev See {IERC4626-mint}. */
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        // Use previewMint() to calculate the amount of underlying assets required for deposit
        assets = previewMint(shares);

        // Transfer first, then mint to prevent reentry
        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        // Release Deposit Event
        emit Deposit(msg.sender, receiver, assets, shares);

    }

    /** @dev See {IERC4626-withdraw}. */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        // Use previewWithdraw() to calculate the share of the vault that will be destroyed
        shares = previewWithdraw(assets);

        // If the caller is not the owner, check and update authorization
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // Destroy first and then transfer to prevent reentry
        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        // Release the Withdraw function
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    /** @dev See {IERC4626-redeem}. */
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        // Use previewRedeem() to calculate the amount of underlying assets that can be redeemed
        assets = previewRedeem(shares);

        // If the caller is not the owner, check and update authorization
        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        // Destroy first and then transfer to prevent reentry
        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        // Release the Withdraw function
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    // Accounting Logic
    /** @dev See {IERC4626-totalAssets}. */
    function totalAssets() public view virtual returns (uint256){
        // Returns the underlying asset position in the contract
        return _asset.balanceOf(address(this));
    }

    /** @dev See {IERC4626-convertToShares}. */
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply();
        // If supply is 0, then 1:1 minting vault share
        // If supply is not 0, then cast proportionally
        return supply == 0 ? assets : assets * supply / totalAssets();
    }

    /** @dev See {IERC4626-convertToAssets}. */
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply();
        // If supply is 0, then redeem the underlying asset 1:1
        // If supply is not 0, redeem in proportion
        return supply == 0 ? shares : shares * totalAssets() / supply;
    }

    /** @dev See {IERC4626-previewDeposit}. */
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    /** @dev See {IERC4626-previewMint}. */
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /** @dev See {IERC4626-previewWithdraw}. */
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    /** @dev See {IERC4626-previewRedeem}. */
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/
    /** @dev See {IERC4626-maxDeposit}. */
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /** @dev See {IERC4626-maxMint}. */
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    
    /** @dev See {IERC4626-maxWithdraw}. */
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }
    
    /** @dev See {IERC4626-maxRedeem}. */
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }
}
