# Subscription NFT Platform Deployment Guide

## Overview
The Subscription NFT Platform is a multi-chain subscription system leveraging Reactive Network for event-driven automation. It consists of contracts deployed on L1 chains (Sepolia, etc.) and the Reactive Network.

## Local Testing Status
- **21 out of 27 tests passing** ✅
- Core functionality verified:
  - Payment processing
  - NFT minting and renewals
  - Multi-token support (ETH, USDC, WETH)
  - Grace period management
  - Debt tracking
  - Mock Reactive Network integration

## Prerequisites

### 1. Environment Setup
Create a `.env` file with your private key:
```env
PRIVATE_KEY=dfe9a1d1c29b40417ee15201f33240236c1750f4ce60fe32ba809a673ab24f99
SEPOLIA_RPC_URL=https://sepolia.gateway.tenderly.co
REACTIVE_RPC_URL=https://lasna-rpc.rnk.dev/
REACTIVE_PRIVATE_KEY=dfe9a1d1c29b40417ee15201f33240236c1750f4ce60fe32ba809a673ab24f99
```

### 2. Get REACT Tokens
Send Sepolia ETH to the Reactive Faucet to receive REACT tokens (5x multiplier):
```bash
# Send 0.01 ETH to get 0.05 REACT
cast send 0x9b9BB25f1A81078C544C829c5EB7822d747Cf434 \
  --rpc-url https://sepolia.gateway.tenderly.co \
  --private-key dfe9a1d1c29b40417ee15201f33240236c1750f4ce60fe32ba809a673ab24f99 \
  --value 0.01ether
```

## Deployment Process

### Step 1: Deploy to Sepolia (L1)

Deploy SubscriptionManager and SubscriptionNFT:
```bash
forge script script/DeployL1.s.sol:DeployL1 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

This will deploy:
- `SubscriptionManager`: Handles merchant registration and payment processing
- `SubscriptionNFT`: ERC-1155 NFT representing active subscriptions

### Step 2: Deploy to Reactive Network

Deploy the SubscriptionReactive contract:
```bash
forge create src/SubscriptionReactive.sol:SubscriptionReactive \
  --rpc-url $REACTIVE_RPC_URL \
  --private-key $REACTIVE_PRIVATE_KEY \
  --value 0.1ether \
  --constructor-args <MANAGER_ADDRESS> <NFT_ADDRESS> 11155111
```

Replace:
- `<MANAGER_ADDRESS>`: SubscriptionManager address from Step 1
- `<NFT_ADDRESS>`: SubscriptionNFT address from Step 1
- `11155111`: Sepolia chain ID

### Step 3: Configure Contracts

1. Set the Reactive contract address in SubscriptionNFT:
```bash
cast send <NFT_ADDRESS> "setReactiveContract(address)" <REACTIVE_CONTRACT> \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

2. Grant REACTIVE_ROLE to the Reactive contract:
```bash
cast send <NFT_ADDRESS> "grantRole(bytes32,address)" \
  0xe286d85d055d9c4dcf75801079a9370d8cc2d35db53d804b5b94584572b4c022 \
  <REACTIVE_CONTRACT> \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Step 4: Subscribe to Events

Subscribe the Reactive contract to payment events:
```bash
cast send <REACTIVE_CONTRACT> "subscribe(uint256,address,bytes32,bytes32,bytes32,bytes32)" \
  11155111 \
  <MANAGER_ADDRESS> \
  0x963828b78055ed788a775c5912101b4833a80b32fff96e3fecd0ab3a63d8233b \
  0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad \
  0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad \
  0x0000000000000000000000000000000000000000000000000000000000000000 \
  --rpc-url $REACTIVE_RPC_URL \
  --private-key $REACTIVE_PRIVATE_KEY \
  --value 0.01ether
```

## Testing the Deployment

### 1. Register a Merchant
```bash
cast send <MANAGER_ADDRESS> "registerMerchant(address,uint64,uint64)" \
  <MERCHANT_WALLET> 2592000 604800 \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY
```

### 2. Create a Subscription
Send payment with the correct event data to trigger a subscription.

### 3. Check Subscription Status
```bash
cast call <NFT_ADDRESS> "isSubscriptionActive(address,uint256)" \
  <USER_ADDRESS> <MERCHANT_ID> \
  --rpc-url $SEPOLIA_RPC_URL
```

## Contract Addresses

### Sepolia (after deployment)
- SubscriptionManager: `<TO_BE_DEPLOYED>`
- SubscriptionNFT: `<TO_BE_DEPLOYED>`

### Reactive Network (after deployment)
- SubscriptionReactive: `<TO_BE_DEPLOYED>`

## Architecture

```
┌─────────────────┐         ┌─────────────────┐
│   Sepolia L1    │         │Reactive Network │
│                 │         │                 │
│ ┌─────────────┐ │         │ ┌─────────────┐ │
│ │ Subscription│ │ Events  │ │Subscription │ │
│ │   Manager   │◄├─────────┤►│  Reactive   │ │
│ └─────────────┘ │         │ └─────────────┘ │
│                 │         │        │        │
│ ┌─────────────┐ │         │        ▼        │
│ │Subscription │◄├─────────┤  Callback to    │
│ │     NFT     │ │         │   mint/renew    │
│ └─────────────┘ │         │                 │
└─────────────────┘         └─────────────────┘
```

## Troubleshooting

### Not receiving REACT tokens
- Wait 1-2 minutes after sending ETH to the faucet
- Check balance: `cast balance <YOUR_ADDRESS> --rpc-url https://lasna-rpc.rnk.dev/`

### Subscription not created
- Verify the Reactive contract is subscribed to events
- Check that REACTIVE_ROLE is granted to the Reactive contract
- Ensure sufficient REACT tokens for gas

### Gas estimation issues
- The Reactive Network requires REACT tokens for gas
- Ensure your Reactive wallet has sufficient balance

## Support

For issues or questions:
- GitHub: https://github.com/anthropics/claude-code/issues
- Documentation: https://docs.reactive.network/