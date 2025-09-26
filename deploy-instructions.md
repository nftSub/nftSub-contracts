# Deployment Instructions

## Wallet Information
- **Address**: `0xcBe96Ca7899a20d21F78b74A6A93e424bfD54941`
- **Keystore Name**: `deployer`
- **Password**: `Abubakr1234#`

## Deployment Commands

### 1. Fund the wallet on each chain first:
- BSC: Send ~0.01 BNB
- Base: Send ~0.001 ETH
- Arbitrum: Send ~0.001 ETH
- Avalanche: Send ~0.1 AVAX
- Sonic: Send ~1 S
- Reactive: Send ~0.1 RNK

### 2. Deploy to each chain:

```bash
# BSC
forge script script/DeployToChain.s.sol --rpc-url https://bsc-dataseed1.binance.org --account deployer --password Abubakr1234# --broadcast

# Base
forge script script/DeployToChain.s.sol --rpc-url https://mainnet.base.org --account deployer --password Abubakr1234# --broadcast

# Arbitrum
forge script script/DeployToChain.s.sol --rpc-url https://arb1.arbitrum.io/rpc --account deployer --password Abubakr1234# --broadcast

# Avalanche
forge script script/DeployToChain.s.sol --rpc-url https://api.avax.network/ext/bc/C/rpc --account deployer --password Abubakr1234# --broadcast

# Sonic
forge script script/DeployToChain.s.sol --rpc-url https://rpc.soniclabs.com --account deployer --password Abubakr1234# --broadcast
```

### 3. After all chains are deployed, update Reactive script with addresses and deploy:

```bash
# Reactive Network
forge script script/DeployReactive.s.sol --rpc-url https://mainnet-rpc.rnk.dev/ --account deployer --password Abubakr1234# --broadcast
```

## Security Notes
- This is a fresh wallet generated locally
- Keep the password secure
- Never commit the keystore file or password to git
- Test with small amounts first