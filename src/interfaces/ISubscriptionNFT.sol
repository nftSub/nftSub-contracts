// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ISubscriptionTypes.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @title ISubscriptionNFT
/// @notice ERC-1155 NFTs representing active subscriptions (deployed on destination chain)
interface ISubscriptionNFT is IERC1155, ISubscriptionTypes {
    
    // ============ Events ============
    
    event SubscriptionMinted(
        address indexed user,
        uint256 indexed merchantId,
        uint64 expiresAt,
        uint32 renewalCount
    );
    
    event SubscriptionRenewed(
        address indexed user,
        uint256 indexed merchantId,
        uint64 newExpiresAt,
        uint32 renewalCount
    );
    
    event SubscriptionExpired(
        address indexed user,
        uint256 indexed merchantId
    );
    
    event SubscriptionBurned(
        address indexed user,
        uint256 indexed merchantId
    );
    
    // ============ Subscription Management ============
    
    /// @notice Mint or renew subscription NFT (called by SubscriptionManager or via Reactive callback)
    /// @param user Address receiving the NFT
    /// @param merchantId Token ID representing the merchant
    /// @param additionalPeriod Seconds to add to subscription
    function mintOrRenew(
        address user,
        uint256 merchantId,
        uint64 additionalPeriod
    ) external;
    
    /// @notice Burn expired subscription NFTs
    /// @param user NFT owner
    /// @param merchantId Token ID to burn
    function burnExpired(
        address user,
        uint256 merchantId
    ) external;
    
    /// @notice Process batch of expired subscriptions (called by Reactive CRON)
    /// @param users Array of user addresses
    /// @param merchantIds Array of merchant IDs
    function processBatchExpiry(
        address[] calldata users,
        uint256[] calldata merchantIds
    ) external;
    
    // ============ Callback Handlers (from Reactive) ============
    
    /// @notice Handle payment callback from Reactive Network
    /// @param user User who made payment
    /// @param merchantId Merchant receiving payment
    /// @param expiresAt New expiration timestamp
    function onPaymentProcessed(
        address user,
        uint256 merchantId,
        uint64 expiresAt
    ) external;
    
    /// @notice Implements pay() for Reactive callback debt settlement
    /// @return Amount paid to settle debt
    function pay() external payable returns (uint256);
    
    // ============ View Functions ============
    
    /// @notice Check if subscription is currently active
    /// @param user Subscription owner
    /// @param merchantId Merchant subscription
    /// @return active True if subscription is active
    function isSubscriptionActive(
        address user,
        uint256 merchantId
    ) external view returns (bool active);
    
    /// @notice Get full subscription status
    /// @param user Subscription owner  
    /// @param merchantId Merchant subscription
    /// @return status Subscription details
    function getSubscriptionStatus(
        address user,
        uint256 merchantId
    ) external view returns (SubscriptionStatus memory status);
    
    /// @notice Get remaining time on subscription
    /// @param user Subscription owner
    /// @param merchantId Merchant subscription
    /// @return remainingTime Seconds until expiry (0 if expired)
    function getRemainingTime(
        address user,
        uint256 merchantId
    ) external view returns (uint256 remainingTime);
    
    /// @notice Check if in grace period
    /// @param user Subscription owner
    /// @param merchantId Merchant subscription
    /// @return inGrace True if expired but in grace period
    function isInGracePeriod(
        address user,
        uint256 merchantId
    ) external view returns (bool inGrace);
}