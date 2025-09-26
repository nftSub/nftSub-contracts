# Sonic Mainnet Deployment

## Network Information
- **Network**: Sonic Mainnet
- **Chain ID**: 146
- **RPC URL**: https://rpc.soniclabs.com
- **Explorer**: https://sonicscan.org

## Deployed Contracts

### SubscriptionManager
- **Address**: `0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c`
- **Explorer**: [View on SonicScan](https://sonicscan.org/address/0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c)
- **Deployment Date**: September 26, 2025

### SubscriptionNFT
- **Address**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`
- **Explorer**: [View on SonicScan](https://sonicscan.org/address/0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8)
- **Deployment Date**: September 26, 2025
- **Metadata URI**: `https://nft-sub.vercel.app/api/metadata/146/{id}`

### Callback Proxy (Reactive Network)
- **Address**: `0x9299472a6399fd1027ebf067571eb3e3d7837fc4`
- **Note**: This is the Reactive Network callback proxy for Sonic chain

## Contract Configuration

### SubscriptionManager Settings
- **Platform Fee**: 2.5% (250 basis points)
- **Owner**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **NFT Contract**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`

### Supported Payment Tokens
To be configured by admin:
- **S**: Native token (address: `0x0000000000000000000000000000000000000000`)
- Additional tokens to be added as needed

## Deployment Information

### Deployer
- **Address**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **Deployment Cost**: ~0.95 S
- **Gas Used**: ~8,659,641 gas units
- **Gas Price**: ~110 gwei

### Deployment Script
```bash
PRIVATE_KEY=0x... forge script script/DeployToChain.s.sol \
  --rpc-url https://rpc.soniclabs.com \
  --broadcast
```

## Integration

### SDK Configuration
```typescript
const config = {
  sonic: {
    subscriptionManager: '0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c',
    subscriptionNFT: '0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8',
    callbackProxy: '0x9299472a6399fd1027ebf067571eb3e3d7837fc4',
    chainId: 146,
    rpcUrl: 'https://rpc.soniclabs.com'
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
// With S (native token)
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe{value: price}(
  merchantId,
  address(0) // S
);

// With ERC20
IERC20(tokenAddress).approve(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c, price);
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe(
  merchantId,
  tokenAddress
);
```

## Next Steps

1. **Fund Deployer Wallet**
   - Send at least 1 S to `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
   - Execute deployment script

2. **Configure Token Support**
   - Admin needs to whitelist payment tokens
   - Set merchant prices for each token

3. **Deploy Reactive Contract**
   - Deploy SubscriptionReactive on Reactive Network
   - Configure with Sonic SubscriptionManager address
   - Subscribe to events from Sonic chain

4. **Test Functionality**
   - Register test merchant
   - Create test subscription
   - Verify NFT minting and metadata

## Security Considerations

- Contracts are non-upgradeable
- Owner can set platform fees and pause functionality
- Merchants control their own pricing and payout addresses
- NFTs follow ERC-1155 standard with subscription expiry tracking

## Support

For issues or questions:
- GitHub: https://github.com/nftSub
- Documentation: https://nft-sub.vercel.app/docs