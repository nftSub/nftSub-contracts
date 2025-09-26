# Base Mainnet Deployment

## Network Information
- **Network**: Base Mainnet
- **Chain ID**: 8453
- **RPC URL**: https://mainnet.base.org
- **Explorer**: https://basescan.org

## Deployed Contracts

### SubscriptionManager
- **Address**: `0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c`
- **Explorer**: [View on BaseScan](https://basescan.org/address/0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c)
- **Deployment Date**: September 26, 2025

### SubscriptionNFT
- **Address**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`
- **Explorer**: [View on BaseScan](https://basescan.org/address/0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8)
- **Deployment Date**: September 26, 2025
- **Metadata URI**: `https://nft-sub.vercel.app/api/metadata/8453/{id}`

### Callback Proxy (Reactive Network)
- **Address**: `0x0D3E76De6bC44309083cAAFdB49A088B8a250947`
- **Note**: This is the Reactive Network callback proxy for Base chain

## Contract Configuration

### SubscriptionManager Settings
- **Platform Fee**: 2.5% (250 basis points)
- **Owner**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **NFT Contract**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`

### Supported Payment Tokens
To be configured by admin:
- **ETH**: Native token (address: `0x0000000000000000000000000000000000000000`)
- **USDC**: `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`
- **WETH**: `0x4200000000000000000000000000000000000006`

## Deployment Information

### Deployer
- **Address**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **Deployment Cost**: ~0.00057 ETH
- **Gas Used**: ~8,659,657 gas units
- **Gas Price**: ~0.066 gwei

### Deployment Script
```bash
forge script script/DeployToChain.s.sol \
  --rpc-url https://mainnet.base.org \
  --broadcast
```

## Integration

### SDK Configuration
```typescript
const config = {
  base: {
    subscriptionManager: '0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c',
    subscriptionNFT: '0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8',
    callbackProxy: '0x0D3E76De6bC44309083cAAFdB49A088B8a250947',
    chainId: 8453,
    rpcUrl: 'https://mainnet.base.org'
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
// With ETH
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe{value: price}(
  merchantId,
  address(0) // ETH
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
   - Admin needs to whitelist payment tokens (USDC, WETH, etc.)
   - Set merchant prices for each token

2. **Deploy Reactive Contract**
   - Deploy SubscriptionReactive on Reactive Network
   - Configure with Base SubscriptionManager address
   - Subscribe to events from Base chain

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