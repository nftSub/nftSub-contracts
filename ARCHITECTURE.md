# Subscription NFT Platform Architecture

## Overview
A decentralized subscription management platform using NFTs to represent active subscriptions. The system leverages Reactive Network's event-driven architecture to automate subscription tracking and renewals across chains.

## Three-Contract Architecture

### 1. SubscriptionManager.sol (L1 - Destination Chain)
**Purpose**: Core payment processing and merchant management
**Deployment**: Ethereum mainnet/L2s where payments occur

**Key Features**:
- Merchant registration and plan management
- Payment processing for subscriptions
- Pull-based withdrawal pattern for merchant earnings
- Platform fee collection
- Emits PaymentReceived events for Reactive monitoring

**Flow**:
1. Merchants register and set subscription prices
2. Users pay for subscriptions via `subscribe()`
3. Payment event emitted
4. Funds held in contract for pull-based withdrawal

### 2. SubscriptionNFT.sol (L1 - Destination Chain)
**Purpose**: ERC-1155 NFTs representing active subscriptions
**Deployment**: Same chain as SubscriptionManager

**Key Features**:
- Mints NFT on subscription purchase/renewal
- Burns NFT on expiry (after grace period)
- Implements callback receiver from Reactive
- Tracks subscription status and renewal counts
- Implements `pay()` for Reactive debt settlement

**Flow**:
1. Receives callbacks from Reactive Network
2. Mints/renews NFTs based on payment events
3. Burns expired NFTs via batch processing

### 3. SubscriptionReactive.sol (Reactive Network)
**Purpose**: Event monitoring and callback orchestration
**Deployment**: Reactive Network only

**Key Features**:
- Inherits from AbstractReactive
- Subscribes to PaymentReceived events
- Subscribes to CRON for periodic expiry checks
- Processes events and triggers callbacks
- Manages debt for cross-chain transactions

**Flow**:
1. Monitors PaymentReceived events from SubscriptionManager
2. Triggers callback to SubscriptionNFT for minting
3. CRON checks for expired subscriptions
4. Batch processes expiries

## Event Flow Architecture

```
User pays on L1 → SubscriptionManager emits PaymentReceived
                            ↓
                  Reactive Network detects event
                            ↓
              SubscriptionReactive.react() processes
                            ↓
                  Emits Callback to L1
                            ↓
            SubscriptionNFT.onPaymentProcessed()
                            ↓
                    NFT minted/renewed
```

## Key Design Patterns

### 1. Pull-Based Withdrawals
Merchants and platform pull funds rather than automatic transfers, reducing gas costs and improving security.

### 2. Batch Processing
Expired subscriptions processed in batches via CRON to optimize gas usage.

### 3. Grace Period
Configurable grace period before NFT burn, allowing for payment retry or manual intervention.

### 4. Debt Management
Reactive Network uses debt-based system where callbacks accrue debt that must be settled.

### 5. Multi-Token Support
Each merchant can accept multiple payment tokens with different prices.

## Security Considerations

1. **Access Control**: Only authorized contracts can trigger callbacks
2. **Reentrancy Protection**: Using checks-effects-interactions pattern
3. **Pull Pattern**: Prevents forced transfers and reduces attack surface
4. **Validation**: All callbacks validated for proper source and data

## Gas Optimization

1. **Batch Operations**: Multiple operations in single transaction
2. **Event Filtering**: Using indexed parameters for efficient queries
3. **Storage Packing**: Optimized struct layouts
4. **Minimal Storage**: Using events for historical data

## Deployment Order

1. Deploy SubscriptionManager on L1
2. Deploy SubscriptionNFT on L1
3. Deploy SubscriptionReactive on Reactive Network
4. Initialize SubscriptionReactive with L1 contract addresses
5. Configure event subscriptions
6. Fund Reactive contract for operations