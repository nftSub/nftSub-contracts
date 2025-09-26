# Multi-Chain Deployment Status

## Deployer Address
`0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`

## Deployment Status by Chain

### ✅ Base (Chain ID: 8453) - DEPLOYED
- **Status**: ✅ Deployed
- **Actual Cost**: ~0.00057 ETH
- **Gas Price**: 0.066 gwei
- **Gas Used**: 8,659,657 units
- **Contracts Deployed**: ✅

### ✅ BSC (Chain ID: 56) - DEPLOYED
- **Status**: ✅ Deployed
- **Actual Cost**: ~0.000433 BNB
- **Gas Price**: 0.05 gwei
- **Gas Used**: 8,659,625 units
- **Contracts Deployed**: ✅

### ✅ Avalanche C-Chain (Chain ID: 43114) - DEPLOYED
- **Status**: ✅ Deployed
- **Actual Cost**: ~0.0235 AVAX
- **Gas Price**: 2.715 gwei
- **Gas Used**: 8,659,672 units
- **Contracts Deployed**: ✅

### 🟡 Sonic (Chain ID: 146) - READY
- **Status**: Ready to deploy (awaiting funds)
- **Required**: **0.95 S**
- **Send**: **1 S** (with buffer)
- **Gas Price**: 110 gwei
- **Estimated Gas**: 8,659,641 units
- **Note**: Will deploy to same addresses

### 🟡 Reactive Network (Chain ID: 1597)
- **Status**: Awaiting other deployments
- **Estimated**: ~0.1 RNK
- **Note**: Deploy after all destination chains

## Remaining Deployments

For remaining chains:
- **Sonic**: 1 S (ready to deploy when funded)
- **Reactive**: 0.1 RNK (deploy after all destination chains)

## Deployment Summary

1. ✅ Base - COMPLETE
2. ✅ BSC - COMPLETE  
3. ✅ Avalanche - COMPLETE
4. 🟡 Sonic - Ready (need 1 S)
5. 🟡 Reactive Network - (deploy after Sonic)

## Contract Addresses (Same on all chains due to CREATE2)

- **SubscriptionManager**: `0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c`
- **SubscriptionNFT**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`

## Deployment Command

For Sonic (once funded):
```bash
# Sonic
PRIVATE_KEY=0xe29cc05187692615b6c04079c13b450e08ad1d0d9b8ecb35aa794687b91bd678 \
forge script script/DeployToChain.s.sol --rpc-url https://rpc.soniclabs.com --broadcast
```

## Notes
- All deployments use the same wallet for consistent addresses
- Successfully deployed to Base, BSC, and Avalanche with same contract addresses
- Sonic ready to deploy once funded (will have same addresses)
- Arbitrum deployment skipped due to high costs