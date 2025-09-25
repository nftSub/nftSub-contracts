// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ISubscriptionTypes
/// @notice Core types used across the subscription platform
interface ISubscriptionTypes {
    
    /// @notice Event subscription structure for Reactive Network
    struct Subscription {
        uint256 chain_id;
        address _contract;
        uint256 topic_0;
        uint256 topic_1;
        uint256 topic_2;
        uint256 topic_3;
    }

    /// @notice Merchant subscription plan details
    struct MerchantPlan {
        address payoutAddress;      // Where merchant withdraws funds
        uint64 subscriptionPeriod;  // Duration in seconds
        uint64 gracePeriod;         // Grace period before burn
        bool isActive;              // Plan accepting new subs
        uint256 totalSubscribers;   // Current active subscribers
    }

    /// @notice Individual subscription status
    struct SubscriptionStatus {
        uint64 expiresAt;           // Expiration timestamp
        uint64 startedAt;           // Start timestamp
        uint32 renewalCount;        // Times renewed
        uint128 lastPaymentAmount;  // Last payment in wei
        address paymentToken;       // Token used for payment
        bool autoRenew;            // Auto-renewal enabled
    }

    /// @notice Payment record for tracking
    struct PaymentRecord {
        uint256 merchantId;
        address user;
        address paymentToken;
        uint256 amount;
        uint256 platformFee;
        uint64 timestamp;
        uint256 blockNumber;
    }

    /// @notice Merchant balance info
    struct MerchantBalance {
        uint256 totalReceived;      // Total payments received
        uint256 totalWithdrawn;     // Total withdrawn
        uint256 pendingAmount;      // Available to withdraw
        uint64 lastWithdrawal;      // Last withdrawal timestamp
    }
}