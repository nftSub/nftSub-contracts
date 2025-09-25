// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ISubscriptionTypes.sol";
import "../../lib/reactive-lib/src/interfaces/IReactive.sol";

/// @title ISubscriptionReactive
/// @notice Reactive contract deployed on Reactive Network for event monitoring
interface ISubscriptionReactive is IReactive, ISubscriptionTypes {
    
    // ============ Configuration ============
    
    /// @notice Initialize reactive monitoring
    /// @param subscriptionManager Address on destination chain
    /// @param subscriptionNFT Address on destination chain
    /// @param destinationChainId Chain ID to send callbacks to
    function initialize(
        address subscriptionManager,
        address subscriptionNFT,
        uint256 destinationChainId
    ) external;
    
    /// @notice Subscribe to payment events from destination chain
    /// @param chainId Chain to monitor
    /// @param contractAddress Contract emitting events
    function subscribeToPaymentEvents(
        uint256 chainId,
        address contractAddress
    ) external;
    
    /// @notice Subscribe to CRON for periodic checks
    /// @param interval CRON interval constant
    function subscribeToCron(uint256 interval) external;
    
    /// @notice Pause all subscriptions
    function pause() external;
    
    /// @notice Resume all subscriptions
    function resume() external;
    
    // ============ Event Processing (Inherited from IReactive) ============
    // function react(LogRecord calldata log) external; // Already in IReactive
    
    // ============ State Management ============
    
    /// @notice Track subscription state across chains
    /// @param user User address
    /// @param merchantId Merchant identifier
    /// @param expiresAt Expiration timestamp
    function updateSubscriptionState(
        address user,
        uint256 merchantId,
        uint64 expiresAt
    ) external;
    
    /// @notice Get tracked expiration for monitoring
    /// @param user User address
    /// @param merchantId Merchant identifier
    /// @return expiresAt Tracked expiration
    function getTrackedExpiration(
        address user,
        uint256 merchantId
    ) external view returns (uint64 expiresAt);
    
    /// @notice Get list of subscriptions expiring soon
    /// @param beforeTimestamp Check expiry before this time
    /// @param limit Max results to return
    /// @return users Array of user addresses
    /// @return merchantIds Array of merchant IDs
    function getExpiringSubscriptions(
        uint64 beforeTimestamp,
        uint256 limit
    ) external view returns (
        address[] memory users,
        uint256[] memory merchantIds
    );
    
    // ============ Debt Management (Required by Reactive) ============
    
    // coverDebt() is inherited from IPayer through IReactive
    
    /// @notice Get current debt amount
    function getDebt() external view returns (uint256);
    
    /// @notice Deposit funds for future RVM transactions
    function depositForOperations() external payable;
    
    // ============ Admin Functions ============
    
    /// @notice Update callback gas limit
    /// @param newLimit New gas limit for callbacks
    function updateCallbackGasLimit(uint64 newLimit) external;
    
    /// @notice Emergency withdraw (owner only)
    function emergencyWithdraw() external;
}