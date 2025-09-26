# BSC Mainnet Deployment

## Network Information
- **Network**: Binance Smart Chain (BSC) Mainnet
- **Chain ID**: 56
- **RPC URL**: https://bsc-dataseed1.binance.org
- **Explorer**: https://bscscan.com

## Deployed Contracts

### SubscriptionManager
- **Address**: `0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c`
- **Explorer**: [View on BscScan](https://bscscan.com/address/0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c)
- **Deployment Date**: September 26, 2025

### SubscriptionNFT
- **Address**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`
- **Explorer**: [View on BscScan](https://bscscan.com/address/0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8)
- **Deployment Date**: September 26, 2025
- **Metadata URI**: `https://nft-sub.vercel.app/api/metadata/56/{id}`

### Callback Proxy (Reactive Network)
- **Address**: `0xdb81A196A0dF9Ef974C9430495a09B6d535fAc48`
- **Note**: This is the Reactive Network callback proxy for BSC chain

## Contract Configuration

### SubscriptionManager Settings
- **Platform Fee**: 2.5% (250 basis points)
- **Owner**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **NFT Contract**: `0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8`

### Supported Payment Tokens
To be configured by admin:
- **BNB**: Native token (address: `0x0000000000000000000000000000000000000000`)
- **USDT**: `0x55d398326f99059fF775485246999027B3197955`
- **BUSD**: `0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56`
- **WBNB**: `0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c`

## Deployment Information

### Deployer
- **Address**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **Deployment Cost**: ~0.000433 BNB
- **Gas Used**: ~8,659,625 gas units
- **Gas Price**: ~0.05 gwei

### Deployment Script
```bash
forge script script/DeployToChain.s.sol \
  --rpc-url https://bsc-dataseed1.binance.org \
  --account deployer --password Abubakr1234# \
  --broadcast
```

## Integration

### SDK Configuration
```typescript
const config = {
  bsc: {
    subscriptionManager: '0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c',
    subscriptionNFT: '0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8',
    callbackProxy: '0xdb81A196A0dF9Ef974C9430495a09B6d535fAc48',
    chainId: 56,
    rpcUrl: 'https://bsc-dataseed1.binance.org'
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
// With BNB
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe{value: price}(
  merchantId,
  address(0) // BNB
);

// With BEP20
IERC20(tokenAddress).approve(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c, price);
ISubscriptionManager(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c).subscribe(
  merchantId,
  tokenAddress
);
```

## Next Steps

1. **Configure Token Support**
   - Admin needs to whitelist payment tokens (USDT, BUSD, WBNB, etc.)
   - Set merchant prices for each token

2. **Deploy to Remaining Chains**
   - Arbitrum One (need 0.002 ETH)
   - Avalanche C-Chain (need 0.035 AVAX)
   - Sonic (need ~1 S)

3. **Deploy Reactive Contract**
   - Deploy SubscriptionReactive on Reactive Network
   - Configure with BSC SubscriptionManager address
   - Subscribe to events from BSC chain

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