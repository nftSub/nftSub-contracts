# Sepolia Deployment Status

## ✅ DEPLOYMENT COMPLETE

## L1 Contracts (Sepolia - Chain ID: 11155111)

### SubscriptionManager
- **Address**: `0x82b069578ae3dA9ea740D24934334208b83E530E`
- **Status**: ✅ Deployed and verified
- **Verified**: Has code on-chain
- **Configuration**:
  - SubscriptionNFT set: ✅
  - Supported tokens: Ready to configure

### SubscriptionNFT  
- **Address**: `0x404cb817FA393D3689D1405DB0B76a20eDE72d43`
- **Status**: ✅ Deployed and verified
- **Verified**: Has code on-chain
- **Configuration**:
  - Manager contract: `0x82b069578ae3dA9ea740D24934334208b83E530E` ✅
  - Reactive contract: `0xa55B7A74D05b5D5C48E431e44Fea83a1047A7582` ✅
  - REACTIVE_ROLE granted to reactive: ✅

### Test Token (MockERC20)
- **Address**: `0x10586EBF2Ce1F3e851a8F15659cBa15b03Eb8B8A`
- **Symbol**: SUBTEST (Subscription Test Token)
- **Decimals**: 18
- **Status**: ✅ Deployed
- **Configuration**:
  - Merchant ID 1 configured with price: 0.01 SUBTEST

## Reactive Network Contracts

### SubscriptionReactive
- **Address**: `0xa55B7A74D05b5D5C48E431e44Fea83a1047A7582`
- **Network**: Reactive Testnet (Lasna)
- **Status**: ✅ Deployed and initialized
- **Verified**: Has code on-chain
- **Configuration**:
  - Target Chain ID: 11155111 (Sepolia) ✅
  - Subscription Manager: `0x82b069578ae3dA9ea740D24934334208b83E530E` ✅
  - Subscription NFT: `0x404cb817FA393D3689D1405DB0B76a20eDE72d43` ✅
  - Payment events subscription: ✅ Active
  - CRON subscription (hourly): ✅ Active
  - REACT deposit: 0.01 REACT ✅

## Deployment Summary

### Completed Steps:
1. ✅ Deployed L1 contracts on Sepolia (SubscriptionManager & SubscriptionNFT)
2. ✅ Verified L1 contracts have code on-chain
3. ✅ Deployed reactive contract on Reactive Network with correct L1 addresses
4. ✅ Initialized reactive contract with proper configuration
5. ✅ Subscribed to payment events from SubscriptionManager
6. ✅ Subscribed to hourly CRON for expiry checks
7. ✅ Set reactive contract address in SubscriptionNFT
8. ✅ Granted REACTIVE_ROLE to reactive contract

### Contract Interaction Flow:
1. Users pay for subscriptions on Sepolia via SubscriptionManager
2. Payment events are captured by SubscriptionReactive on Reactive Network
3. Reactive contract sends callbacks to SubscriptionNFT to mint/update NFTs
4. Hourly CRON checks for expired subscriptions

## Deployment Files

- **L1 Deployment Info**: `/deployments/sepolia-deployment.json`
- **Reactive Deployment Info**: `/deployments/reactive-deployment.json`

## Verification Commands

Check contract code on-chain:
```bash
# L1 Contracts
cast code 0x82b069578ae3dA9ea740D24934334208b83E530E --rpc-url https://sepolia.gateway.tenderly.co
cast code 0x404cb817FA393D3689D1405DB0B76a20eDE72d43 --rpc-url https://sepolia.gateway.tenderly.co

# Reactive Contract
cast code 0xa55B7A74D05b5D5C48E431e44Fea83a1047A7582 --rpc-url https://lasna-rpc.rnk.dev/
```

## Next Steps

1. Configure supported payment tokens in SubscriptionManager
2. Create test subscriptions to verify payment flow
3. Monitor reactive contract logs for event processing
4. Test NFT minting and updates after payments
5. Verify subscription expiry handling via CRON

## Testing Commands

### Register a Test Merchant
```bash
cast send 0x82b069578ae3dA9ea740D24934334208b83E530E \
  "registerMerchant(address,uint64,uint64)" \
  <MERCHANT_WALLET> 2592000 604800 \
  --rpc-url https://sepolia.gateway.tenderly.co \
  --private-key <YOUR_KEY>
```

### Check Subscription Status
```bash
cast call 0x404cb817FA393D3689D1405DB0B76a20eDE72d43 \
  "isSubscriptionActive(address,uint256)" \
  <USER_ADDRESS> <MERCHANT_ID> \
  --rpc-url https://sepolia.gateway.tenderly.co
```

## Resources
- **Reactive Network Docs**: https://docs.reactive.network/
- **Reactive Faucet**: 0x9b9BB25f1A81078C544C829c5EB7822d747Cf434 (5x multiplier)
- **Reactive RPC**: https://lasna-rpc.rnk.dev/
- **Sepolia RPC**: https://sepolia.gateway.tenderly.co