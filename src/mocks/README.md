# Mock Reactive Network System

## Overview

This directory contains a comprehensive mock system that simulates the Reactive Network for local development and testing. The mock system realistically replicates the behavior of the actual Reactive Network, allowing developers to test subscription NFT functionality without deploying to the real Reactive Network.

## Architecture

The mock system consists of four main components:

### 1. MockReactiveNetwork (`MockReactiveNetwork.sol`)

The core mock that simulates the Reactive Network's infrastructure.

**Key Features:**
- **Event Subscriptions**: Subscribe to events from any chain/contract
- **CRON Subscriptions**: Schedule periodic callback triggers
- **Debt Tracking**: Simulates gas costs for callbacks (1 gwei per gas unit)
- **Callback Proxy**: Deploys and manages a mock callback proxy for authentication

**Main Functions:**
```solidity
// Subscribe to events on a destination chain
subscribeToEvents(chainId, contractAddress, topic0, topic1, topic2, topic3)

// Subscribe to periodic CRON triggers
subscribeToCron(interval)

// Simulate an event from the monitored chain
simulateEvent(subscriptionId, txHash, blockNumber, logIndex, indexed_1, indexed_2, data)

// Trigger a CRON event
triggerCron(subscriber)

// Pay accumulated debt from callbacks
payDebt(debtor)
```

### 2. MockCallbackProxy (`MockCallbackProxy.sol`)

Simulates the authentication layer for callbacks from the Reactive Network.

**Purpose:**
- Authenticates that callbacks originate from the Reactive Network
- Forwards authenticated callbacks to target contracts
- Provides security isolation between the mock network and target contracts

**Key Functions:**
```solidity
// Forward an authenticated callback (only callable by MockReactiveNetwork)
forwardCallback(target, data)

// Check if a callback is authentic
isAuthenticCallback()
```

### 3. MockSubscriptionReactive (`MockSubscriptionReactive.sol`)

Mock version of the SubscriptionReactive contract for local testing.

**Features:**
- Processes payment event callbacks
- Handles CRON triggers for expiry checks
- Maintains event deduplication
- Integrates with MockReactiveNetwork instead of real Reactive

**Main Functions:**
```solidity
// Initialize with L1 contract addresses
initialize(subscriptionManager, subscriptionNFT, targetChainId)

// Subscribe to payment events
subscribeToPaymentEvents(chainId, manager)

// Subscribe to CRON for periodic checks
subscribeToCron(interval)

// Process callbacks from mock network
processCallback(txHash, blockNumber, logIndex, subscriber, merchantId, data)
processCronTrigger(timestamp)
```

### 4. ReactiveTestHelper (`ReactiveTestHelper.sol`)

Helper contract providing convenient testing utilities.

**Testing Utilities:**
```solidity
// Simulate a single payment event
simulatePaymentEvent(subscriber, merchantId, paymentToken, amount, expiry)

// Create a complete subscription flow
createSubscriptionFlow(subscriber, merchantId, paymentToken, amount, subscriptionPeriod)

// Batch simulate multiple payments
batchSimulatePayments(subscribers[], merchantIds[], amounts[], expiries[])

// Trigger expiry check via CRON
triggerExpiryCheck()

// Check if CRON can be triggered
canTriggerCron()

// Manage reactive debt
getReactiveDebt()
payReactiveDebt()
```

## Usage

### Local Deployment

When deploying to a local network (chain ID 31337), the deployment script automatically:

1. **Deploys mock tokens** (WETH, USDC, USDT)
2. **Mints test tokens** to the deployer
3. **Deploys MockReactiveNetwork**
4. **Deploys MockCallbackProxy** (via MockReactiveNetwork)
5. **Deploys MockSubscriptionReactive**
6. **Sets up all connections** between contracts
7. **Deploys ReactiveTestHelper** for testing

### Testing Workflow

#### 1. Deploy to Local Network

```bash
# Start local node
anvil

# Deploy with mocks
forge script script/DeployL1.s.sol:DeployL1 --rpc-url http://localhost:8545 --broadcast
```

#### 2. Simulate Payment Events

```javascript
// In your test file
ReactiveTestHelper helper = ReactiveTestHelper(helperAddress);

// Simulate a payment
helper.simulatePaymentEvent(
    subscriber,      // User address
    merchantId,      // Merchant ID
    address(0),      // ETH payment (or token address)
    1 ether,         // Payment amount
    block.timestamp + 30 days  // Subscription expiry
);
```

#### 3. Test CRON Functionality

```javascript
// Check if enough time has passed for CRON
bool canTrigger = helper.canTriggerCron();

if (canTrigger) {
    // Trigger expiry check
    helper.triggerExpiryCheck();
}
```

#### 4. Test Complete Flows

```javascript
// Create a full subscription with automatic NFT minting
helper.createSubscriptionFlow{value: 1 ether}(
    subscriber,
    merchantId,
    address(0),      // ETH payment
    1 ether,
    30 days         // Subscription period
);
```

## Key Differences from Production

### Realistic Simulations
- **Gas costs**: Tracked at 1 gwei per gas unit
- **Event deduplication**: Prevents double-processing
- **Timing constraints**: CRON respects interval requirements
- **Authentication**: Simulates callback proxy authentication

### Simplifications
- **No cross-chain delays**: Events are processed immediately
- **Manual triggering**: Events must be explicitly triggered via helper
- **Simplified debt model**: Fixed gas price calculation
- **No network fees**: Besides tracked debt

## Testing Best Practices

### 1. Setup Phase
```solidity
// Deploy all contracts
// Get helper contract address from deployment
ReactiveTestHelper helper = ReactiveTestHelper(deploymentOutput.helper);
```

### 2. Test Payment Processing
```solidity
// Create a merchant first
uint256 merchantId = manager.createMerchantPlan(...);

// Simulate payment
helper.simulatePaymentEvent(user, merchantId, token, amount, expiry);

// Verify NFT was minted
assertTrue(nft.balanceOf(user, merchantId) > 0);
```

### 3. Test Expiry Handling
```solidity
// Advance time past expiry
vm.warp(block.timestamp + 31 days);

// Trigger CRON
helper.triggerExpiryCheck();

// Verify subscription expired
assertFalse(nft.isSubscriptionActive(user, merchantId));
```

### 4. Test Debt Management
```solidity
// Check accumulated debt
uint256 debt = helper.getReactiveDebt();

// Pay debt
helper.payReactiveDebt{value: debt}();

// Verify debt cleared
assertEqual(helper.getReactiveDebt(), 0);
```

## Debugging

### Event Monitoring
The mock system emits events for debugging:
- `EventSubscribed`: When subscribing to events
- `CronSubscribed`: When setting up CRON
- `CallbackTriggered`: When callbacks are executed
- `EventProcessed`: When events are successfully processed

### Common Issues

**Issue**: Callback not processed
- **Check**: Is the subscription active?
- **Check**: Is the callback sender the mock callback proxy?

**Issue**: CRON not triggering
- **Check**: Has enough time passed since last trigger?
- **Check**: Is the CRON subscription active?

**Issue**: NFT not minted
- **Check**: Was the event processed successfully?
- **Check**: Does the merchant exist in the manager?

## Advanced Usage

### Custom Event Simulation
```solidity
// Direct event simulation with custom data
mockNetwork.simulateEvent(
    subscriptionId,
    keccak256(abi.encode(customData)),  // Custom tx hash
    block.number,
    0,  // Log index
    subscriber,
    merchantId,
    abi.encode(token, amount, expiry)
);
```

### Batch Testing
```solidity
// Test multiple subscriptions at once
address[] memory users = [user1, user2, user3];
uint256[] memory merchants = [1, 1, 2];
uint256[] memory amounts = [1 ether, 2 ether, 1 ether];
uint64[] memory expiries = [expiry1, expiry2, expiry3];

helper.batchSimulatePayments(users, merchants, amounts, expiries);
```

### Time-based Testing
```solidity
// Test subscription lifecycle
helper.simulatePaymentEvent(...);  // Subscribe
vm.warp(block.timestamp + 15 days);  // Mid-subscription
assertTrue(nft.isSubscriptionActive(user, merchantId));

vm.warp(block.timestamp + 31 days);  // Post-expiry
helper.triggerExpiryCheck();
assertFalse(nft.isSubscriptionActive(user, merchantId));
```

## Integration with Foundry Tests

Example test file structure:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/mocks/ReactiveTestHelper.sol";

contract SubscriptionTest is Test {
    ReactiveTestHelper helper;
    SubscriptionManager manager;
    SubscriptionNFT nft;
    
    function setUp() public {
        // Deploy contracts (happens automatically on local)
        // Get deployed addresses from deployment output
        
        helper = ReactiveTestHelper(helperAddress);
        manager = SubscriptionManager(managerAddress);
        nft = SubscriptionNFT(nftAddress);
    }
    
    function testSubscriptionFlow() public {
        // Your test logic using the helper
    }
}
```

## Security Considerations

While the mock system is for testing only:
- **Access Control**: MockCallbackProxy only accepts calls from MockReactiveNetwork
- **Event Deduplication**: Prevents replay attacks in tests
- **Debt Tracking**: Ensures gas costs are accounted for
- **State Isolation**: Each mock maintains independent state

## Maintenance

When updating the production contracts:
1. Update mock interfaces to match
2. Add new event types to `simulateEvent`
3. Update helper functions for new features
4. Maintain realistic gas calculations
5. Keep authentication patterns consistent

## Contributing

When adding new mock functionality:
- Maintain realistic behavior
- Add corresponding helper functions
- Document differences from production
- Include example usage
- Add debugging events