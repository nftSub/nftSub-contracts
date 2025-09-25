// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SubscriptionConstants {
    /// @notice Reactive Network wildcard for ignoring specific topics
    uint256 internal constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    
    /// @notice Event topics we monitor
    bytes32 internal constant PAYMENT_RECEIVED_TOPIC = keccak256("PaymentReceived(address,uint256,address,uint256,uint256,uint64)");
    bytes32 internal constant SUBSCRIPTION_EXPIRED_TOPIC = keccak256("SubscriptionExpired(address,uint256)");
    
    /// @notice CRON intervals (in Reactive Network format)
    uint256 internal constant CRON_EVERY_MINUTE = 0xBBBBBBB000000000000000000000000000000000000000000000000000000001;
    uint256 internal constant CRON_EVERY_HOUR = 0xBBBBBBB00000000000000000000000000000000000000000000000000000003C;
    uint256 internal constant CRON_EVERY_DAY = 0xBBBBBBB000000000000000000000000000000000000000000000000000015180;
    
    /// @notice Default configuration values
    uint64 internal constant DEFAULT_CALLBACK_GAS_LIMIT = 1000000;
    uint16 internal constant DEFAULT_PLATFORM_FEE_BPS = 250; // 2.5%
    uint16 internal constant MAX_FEE_BPS = 1000; // 10% max
    uint64 internal constant DEFAULT_GRACE_PERIOD = 3 days;
}