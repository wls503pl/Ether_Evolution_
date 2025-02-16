// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @dev ERC4626 "The interface contract of the "Tokenized Treasury Standard"
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    // Event
    // Triggered when a deposit is made
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    // Triggered when withdrawing funds
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    // Metadata
    /**
     * @dev Returns the underlying asset token address of the vault (for deposits and withdrawals)
     * - Must be an ERC20 token contract address.
     * - can't revert
     */
    function asset() external view returns (address assetTokenAddress);

    // Deposit/Withdrawal Logic
    /**
     * @dev Deposit function: The user deposits the underlying asset in units of assets into the treasury,
     * and then the contract casts the treasury quota in units of shares to the receiver address
     *
     * - The Deposit event must be released.
     * - If the asset cannot be deposited, it must be reverted, for example, the deposit amount is greater than the upper limit, etc.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Minting function: The user needs to deposit the underlying asset in the unit of assets,
     * and then the contract will mint the treasury quota of the number of shares for the receiver address
     * - The Deposit event must be released.
     * - If the entire treasury amount cannot be minted, it must be reverted, for example, the minting amount is much greater than the upper limit, etc.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Withdrawal function: the owner address destroys the treasury quota of the share unit,
     * and then the contract sends the underlying assets of the assets unit to the receiver address
     * - Release Withdraw event
     * - If all underlying assets cannot be withdrawn, revert
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Redemption function: the owner address destroys the treasury quota of the number of shares,
     * and then the contract sends the underlying assets of the assets unit to the receiver address
     * - Release Withdraw event
     * - If the vault amount cannot be completely destroyed, revert
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    // Accounting Logic
    /**
     * @dev Returns the total amount of base asset tokens managed in the vault
     * - To include interest
     * - To include the cost
     * - Cannot revert
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of treasury that can be exchanged for a certain amount of underlying assets
     * - Don't include fees
     * - No slippage
     * - Cannot revert
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the underlying assets that can be exchanged for a certain amount of treasury quota
     * - Don't include fees
     * - No slippage
     * - Cannot revert
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Used for on-chain and off-chain users to simulate the amount of treasury that can be obtained by depositing
     * a certain amount of basic assets in the current on-chain environment
     * - The return value should be close to but not greater than the vault amount obtained by depositing in the same transaction
     * - Don't consider maxDeposit and other restrictions, assume that the user's deposit transaction will succeed
     * - Consider the cost
     * - can't revert
     * NOTE: Slippage can be calculated using the difference between convertToAssets and previewDeposit
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev The amount of underlying assets required to be deposited by on-chain and off-chain users
     * to simulate the minting of shares in the current on-chain environment.
     * - The return value should be close to and not less than the amount of deposits required to mint a certain amount of vault quota in the same transaction
     * - Don't consider maxMint and other restrictions, assume that the user's deposit transaction will succeed
     * - Consider the cost
     * - Cannot revert
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev The treasury share that needs to be redeemed for the underlying assets used by on-chain and off-chain users
     * to simulate the withdrawal of assets in the current on-chain environment
     * - The return value should be close to but not greater than the vault share required to withdraw a certain amount of underlying assets in the same transaction.
     * - Don't consider maxWithdraw and other restrictions, assume that the user's withdrawal transaction will succeed
     * - Consider the cost
     * - Cannot revert
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev The amount of underlying assets that can be redeemed by the treasury quota used by on-chain and off-chain users
     * to simulate the destruction of shares in the current on-chain environment
     * - The return value must be close to and not less than the amount of underlying assets that can be redeemed
     *   by destroying a certain amount of vault quota in the same transaction
     * - Don't consider maxRedeem and other restrictions, assume that the user's redemption transaction will succeed
     * - Consider the cost
     * - Cannot revert.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    // Deposit/Withdrawal Limit Logic
    /**
     * @dev Returns the maximum amount of underlying assets that can be deposited in a single deposit at a certain user address.
     * - If there is a deposit limit, the return value should be a finite value
     * - The return value cannot exceed 2 ** 256 - 1
     * - Cannot revert
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Returns the maximum amount of treasury that can be minted in a single minting by a certain user address
     * - If there is a casting limit, the return value should be a finite value
     * - The return value cannot exceed 2 ** 256 - 1
     * - Cannot revert
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Returns the maximum amount of underlying assets that can be withdrawn in a single withdrawal from a certain user address
     * - The return value should be a finite value
     * - Cannot revert
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Returns the maximum amount of treasury that can be destroyed in a single redemption of a user address
     * - The return value should be a finite value
     * - If there are no other constraints, the return value should be balanceOf(owner)
     * - Cannot revert
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);
}
