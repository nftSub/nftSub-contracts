// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ISubscriptionTypes.sol";

/// @title ISubscriptionManager  
/// @notice Main contract on destination chain for subscription payments and merchant management
interface ISubscriptionManager is ISubscriptionTypes {
    
    // ============ Events ============
    
    event MerchantRegistered(
        uint256 indexed merchantId,
        address indexed owner,
        address payoutAddress
    );
    
    event PaymentReceived(
        address indexed user,
        uint256 indexed merchantId,
        address indexed paymentToken,
        uint256 amount,
        uint256 platformFee,
        uint64 period
    );
    
    event MerchantWithdrawal(
        uint256 indexed merchantId,
        address indexed token,
        uint256 amount,
        address to
    );
    
    event PlatformFeeWithdrawal(
        address indexed token,
        uint256 amount,
        address to
    );
    
    // ============ Merchant Management ============
    
    /// @notice Register a new merchant
    /// @param payoutAddress Where merchant receives withdrawals
    /// @param subscriptionPeriod Duration in seconds
    /// @param gracePeriod Grace period before NFT burn
    /// @return merchantId Unique merchant identifier
    function registerMerchant(
        address payoutAddress,
        uint64 subscriptionPeriod,
        uint64 gracePeriod
    ) external returns (uint256 merchantId);
    
    /// @notice Update merchant plan details
    function updateMerchantPlan(
        uint256 merchantId,
        address payoutAddress,
        uint64 subscriptionPeriod,
        bool isActive
    ) external;
    
    /// @notice Set price for a specific payment token
    function setMerchantPrice(
        uint256 merchantId,
        address paymentToken,
        uint256 price
    ) external;
    
    // ============ Subscription Payments ============
    
    /// @notice Purchase or renew a subscription
    /// @param merchantId Merchant to subscribe to
    /// @param paymentToken Token used for payment (address(0) for ETH)
    function subscribe(
        uint256 merchantId,
        address paymentToken
    ) external payable;
    
    // ============ Withdrawals (Pull Pattern) ============
    
    /// @notice Merchant withdraws accumulated balance
    /// @param merchantId Merchant ID
    /// @param token Token to withdraw (address(0) for ETH)
    function withdrawMerchantBalance(
        uint256 merchantId,
        address token
    ) external;
    
    /// @notice Platform admin withdraws accumulated fees
    /// @param token Token to withdraw
    /// @param to Recipient address
    function withdrawPlatformFees(
        address token,
        address to
    ) external;
    
    // ============ View Functions ============
    
    /// @notice Get merchant plan details
    function getMerchantPlan(uint256 merchantId) 
        external view returns (MerchantPlan memory);
    
    /// @notice Get merchant's withdrawable balance
    function getMerchantBalance(uint256 merchantId, address token)
        external view returns (uint256);
    
    /// @notice Get price for merchant in specific token
    function getMerchantPrice(uint256 merchantId, address token)
        external view returns (uint256);
    
    /// @notice Check if merchant accepts a payment token
    function isMerchantTokenAccepted(uint256 merchantId, address token)
        external view returns (bool);
    
    /// @notice Get platform fee in basis points (100 = 1%)
    function platformFeeBps() external view returns (uint16);
}