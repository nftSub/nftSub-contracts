# Avalanche C-Chain Mainnet Deployment

## Network Information
- **Network**: Avalanche C-Chain Mainnet
- **Chain ID**: 43114
- **RPC URL**: https://api.avax.network/ext/bc/C/rpc
- **Explorer**: https://snowtrace.io

## Deployed Contracts

### SubscriptionManager
- **Address**: `0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c`
- **Explorer**: [View on SnowTrace](https://snowtrace.io/address/0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c)
- **Deployment Date**: September 26, 2025

### SubscriptionNFT
- **Address**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`
- **Explorer**: [View on SnowTrace](https://snowtrace.io/address/0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8)
- **Deployment Date**: September 26, 2025
- **Metadata URI**: `https://nft-sub.vercel.app/api/metadata/43114/{id}`

### Callback Proxy (Reactive Network)
- **Address**: `0x934Ea75496562D4e83E80865c33dbA600644fCDa`
- **Note**: This is the Reactive Network callback proxy for Avalanche C-Chain

## Contract Configuration

### SubscriptionManager Settings
- **Platform Fee**: 2.5% (250 basis points)
- **Owner**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **NFT Contract**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`

### Supported Payment Tokens
To be configured by admin:
- **AVAX**: Native token (address: `0x0000000000000000000000000000000000000000`)
- **USDC**: `0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E`
- **USDT**: `0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7`
- **WAVAX**: `0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7`

## Deployment Information

### Deployer
- **Address**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **Deployment Cost**: ~0.0235 AVAX
- **Gas Used**: ~8,659,672 gas units
- **Gas Price**: ~2.715 gwei

### Deployment Script
```bash
PRIVATE_KEY=0x... forge script script/DeployToChain.s.sol \
  --rpc-url https://api.avax.network/ext/bc/C/rpc \
  --broadcast
```

## Integration

### SDK Configuration
```typescript
const config = {
  avalanche: {
    subscriptionManager: '0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c',
    subscriptionNFT: '0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8',
    callbackProxy: '0x934Ea75496562D4e83E80865c33dbA600644fCDa',
    chainId: 43114,
    rpcUrl: 'https://api.avax.network/ext/bc/C/rpc'
  }
};
```

### Smart Contract Interaction

#### Register as Merchant
```solidity
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).registerMerchant(
  payoutAddress,
  subscriptionPeriod, // in seconds
  gracePeriod // in seconds
);
```

#### Subscribe to Merchant
```solidity
// With AVAX
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe{value: price}(
  merchantId,
  address(0) // AVAX
);

// With ERC20
IERC20(tokenAddress).approve(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c, price);
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe(
  merchantId,
  tokenAddress
);
```

## Next Steps

1. **Configure Token Support**
   - Admin needs to whitelist payment tokens (USDC, USDT, WAVAX, etc.)
   - Set merchant prices for each token

2. **Deploy Reactive Contract**
   - Deploy SubscriptionReactive on Reactive Network
   - Configure with Avalanche SubscriptionManager address
   - Subscribe to events from Avalanche C-Chain

3. **Test Functionality**
   - Register test merchant
   - Create test subscription
   - Verify NFT minting and metadata

4. **Monitor Events**
   - PaymentReceived
   - SubscriptionMinted
   - SubscriptionRenewed
   - MerchantRegistered

## Security Considerations

- Contracts are non-upgradeable
- Owner can set platform fees and pause functionality
- Merchants control their own pricing and payout addresses
- NFTs follow ERC-1155 standard with subscription expiry tracking

## Support

For issues or questions:
- GitHub: https://github.com/nftSub
- Documentation: https://nft-sub.vercel.app/docs