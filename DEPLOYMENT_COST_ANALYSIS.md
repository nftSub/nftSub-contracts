# NFT Sub - Multi-Chain Deployment Cost Analysis

## Current Deployments (Sepolia Testnet)

### Deployed Contracts
- **SubscriptionNFT**: `0x404cb817FA393D3689D1405DB0B76a20eDE72d43`
- **SubscriptionManager**: `0x82b069578ae3dA9ea740D24934334208b83E530E`  
- **SubscriptionReactive**: `0xa55B7A74D05b5D5C48E431e44Fea83a1047A7582`
- **Target Chain**: Sepolia (Chain ID: 11155111)

## Contract Bytecode Sizes

| Contract | Bytecode Size | Deployment Gas (Est.) |
|----------|--------------|----------------------|
| SubscriptionNFT | 40,463 bytes (~20KB) | ~3,500,000 gas |
| SubscriptionManager | 21,907 bytes (~11KB) | ~2,000,000 gas |
| SubscriptionReactive | 18,723 bytes (~9KB) | ~1,700,000 gas |
| **Total** | **~40KB** | **~7,200,000 gas** |

## Deployment Cost Estimates by Chain

### Base (Coinbase L2)
- **RPC**: https://base.llamarpc.com
- **Gas Price**: ~0.001 Gwei (ultra-low)
- **ETH Price**: $3,500
- **Estimated Cost**: 
  - Per contract: ~$0.01-0.03
  - **Total: ~$0.05-0.10**
- **Native Token Needed**: 0.00001 ETH

### Arbitrum One
- **RPC**: https://arbitrum.rpc.subquery.network/public
- **Gas Price**: ~0.01 Gwei
- **ETH Price**: $3,500
- **Estimated Cost**:
  - Per contract: ~$0.10-0.30
  - **Total: ~$0.50-1.00**
- **Native Token Needed**: 0.0003 ETH

### BNB Chain (Binance Smart Chain)
- **RPC**: https://binance.llamarpc.com
- **Gas Price**: ~3 Gwei
- **BNB Price**: $600
- **Estimated Cost**:
  - Per contract: ~$3-5
  - **Total: ~$10-15**
- **Native Token Needed**: 0.025 BNB

### Avalanche C-Chain
- **RPC**: https://endpoints.omniatech.io/v1/avax/mainnet/public
- **Gas Price**: ~25 nAVAX (25 Gwei)
- **AVAX Price**: $40
- **Estimated Cost**:
  - Per contract: ~$2-4
  - **Total: ~$7-12**
- **Native Token Needed**: 0.3 AVAX

### Sonic (Fantom)
- **RPC**: https://rpc.soniclabs.com
- **Gas Price**: ~50-100 Gwei (variable)
- **S Price**: ~$0.80
- **Estimated Cost**:
  - Per contract: ~$2-5
  - **Total: ~$7-15**
- **Native Token Needed**: 10-20 S
- **Special**: 90% fee rebate program!

## Deployment Strategy

### Priority Order (Cost-Optimized)
1. **Base** - Lowest cost, Coinbase ecosystem
2. **Arbitrum** - Low cost, high TVL
3. **Sonic** - Low cost + 90% fee rebate
4. **Avalanche** - Moderate cost
5. **BNB Chain** - Higher cost but large user base

### Total Budget Required

| Chain | Native Token | USD Value |
|-------|-------------|-----------|
| Base | 0.00001 ETH | $0.10 |
| Arbitrum | 0.0003 ETH | $1.00 |
| BNB Chain | 0.025 BNB | $15.00 |
| Avalanche | 0.3 AVAX | $12.00 |
| Sonic | 20 S | $16.00 |
| **TOTAL** | - | **~$45** |

## SubscriptionReactive Deployment Notes

The `SubscriptionReactive.sol` contract needs to be deployed on **Reactive Network** (not on destination chains). It contains:
- Callback handlers for automated renewals
- Cross-chain message handling
- Subscription state management

**Important**: 
- Only `SubscriptionNFT` and `SubscriptionManager` deploy on each destination chain
- `SubscriptionReactive` remains on Reactive Network and communicates cross-chain
- Each chain deployment needs to register with Reactive Network contract

## Deployment Script Commands

```bash
# Base
forge script script/Deploy.s.sol --rpc-url https://base.llamarpc.com --broadcast

# Arbitrum
forge script script/Deploy.s.sol --rpc-url https://arbitrum.rpc.subquery.network/public --broadcast

# BNB Chain
forge script script/Deploy.s.sol --rpc-url https://binance.llamarpc.com --broadcast

# Avalanche
forge script script/Deploy.s.sol --rpc-url https://endpoints.omniatech.io/v1/avax/mainnet/public --broadcast

# Sonic
forge script script/Deploy.s.sol --rpc-url https://rpc.soniclabs.com --broadcast
```

## Gas Optimization Tips

1. **Deploy during low traffic periods** (weekends, early UTC morning)
2. **Use CREATE2 for deterministic addresses** across chains
3. **Consider proxy patterns** for upgradability (reduces redeployment costs)
4. **Batch deployments** when gas is low

## Return on Investment

With subscription fees of 1-3% vs Stripe's 2.9% + $0.30:
- Break-even after ~15-30 subscriptions per chain
- Sonic's 90% fee rebate makes it essentially free
- Multi-chain presence increases addressable market 5x

## Recommendations

1. **Start with Base & Arbitrum** - Lowest costs, highest adoption
2. **Add Sonic** - Fee rebate program makes it risk-free
3. **Expand to BNB/Avalanche** after initial traction
4. **Keep ~$50 in deployment budget** for all chains
5. **Monitor gas prices** and deploy during optimal times