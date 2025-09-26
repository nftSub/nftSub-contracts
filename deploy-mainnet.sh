#!/bin/bash

# Multi-chain deployment script for nftSub contracts
# Deploys to: BSC, Base, Arbitrum, Avalanche, Sonic, and Reactive Network

set -e  # Exit on error

echo "========================================="
echo "nftSub Multi-Chain Deployment Script"
echo "========================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    echo "Please create a .env file with PRIVATE_KEY"
    exit 1
fi

# Load environment variables
source .env

if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY not set in .env!"
    exit 1
fi

echo "Starting deployment process..."
echo ""

# Deploy to BSC
echo "1. Deploying to BSC..."
forge script script/DeployMultiChain.s.sol:DeployMultiChain \
    --rpc-url https://bsc-dataseed1.binance.org \
    --broadcast \
    --verify \
    --etherscan-api-key $BSC_SCAN_API_KEY \
    -vvvv

# Deploy to Base
echo "2. Deploying to Base..."
forge script script/DeployMultiChain.s.sol:DeployMultiChain \
    --rpc-url https://mainnet.base.org \
    --broadcast \
    --verify \
    --etherscan-api-key $BASE_SCAN_API_KEY \
    -vvvv

# Deploy to Arbitrum
echo "3. Deploying to Arbitrum One..."
forge script script/DeployMultiChain.s.sol:DeployMultiChain \
    --rpc-url https://arb1.arbitrum.io/rpc \
    --broadcast \
    --verify \
    --etherscan-api-key $ARBISCAN_API_KEY \
    -vvvv

# Deploy to Avalanche
echo "4. Deploying to Avalanche..."
forge script script/DeployMultiChain.s.sol:DeployMultiChain \
    --rpc-url https://api.avax.network/ext/bc/C/rpc \
    --broadcast \
    --verify \
    --etherscan-api-key $SNOWTRACE_API_KEY \
    -vvvv

# Deploy to Sonic
echo "5. Deploying to Sonic..."
forge script script/DeployMultiChain.s.sol:DeployMultiChain \
    --rpc-url https://rpc.soniclabs.com \
    --broadcast \
    -vvvv

# Deploy to Reactive Network
echo "6. Deploying to Reactive Network..."
forge script script/DeployMultiChain.s.sol:DeployMultiChain \
    --rpc-url https://mainnet-rpc.rnk.dev/ \
    --broadcast \
    -vvvv

echo ""
echo "========================================="
echo "Deployment complete!"
echo "Check the output above for contract addresses"
echo "========================================="