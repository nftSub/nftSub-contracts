# Subscription NFT Deployment Makefile

-include .env

.PHONY: help build test deploy-sepolia deploy-mainnet deploy-reactive clean

help:
	@echo "Subscription NFT Platform - Deployment Commands"
	@echo ""
	@echo "Usage:"
	@echo "  make build              - Build all contracts"
	@echo "  make test               - Run all tests"
	@echo "  make deploy-sepolia     - Deploy L1 contracts to Sepolia"
	@echo "  make deploy-mainnet     - Deploy L1 contracts to Mainnet"
	@echo "  make deploy-arbitrum    - Deploy L1 contracts to Arbitrum"
	@echo "  make deploy-optimism    - Deploy L1 contracts to Optimism"
	@echo "  make deploy-polygon     - Deploy L1 contracts to Polygon"
	@echo "  make deploy-base        - Deploy L1 contracts to Base"
	@echo "  make deploy-reactive    - Deploy Reactive contract (testnet)"
	@echo "  make deploy-reactive-mainnet - Deploy Reactive contract (mainnet)"
	@echo "  make verify             - Verify contracts on Etherscan"
	@echo "  make clean              - Clean build artifacts"

# Build
build:
	@echo "Building contracts..."
	@forge build

# Test
test:
	@echo "Running tests..."
	@forge test -vvv

# Clean
clean:
	@echo "Cleaning build artifacts..."
	@forge clean
	@rm -rf cache out

# Deploy to Sepolia
deploy-sepolia:
	@echo "Deploying to Sepolia..."
	@forge script script/DeployL1.s.sol:DeployL1 \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		-vvvv

# Deploy to Mainnet
deploy-mainnet:
	@echo "Deploying to Ethereum Mainnet..."
	@echo "WARNING: This will deploy to mainnet. Are you sure? [y/N]"
	@read -r response; \
	if [ "$$response" = "y" ]; then \
		forge script script/DeployL1.s.sol:DeployL1 \
			--rpc-url $(MAINNET_RPC_URL) \
			--private-key $(PRIVATE_KEY) \
			--broadcast \
			--verify \
			--etherscan-api-key $(ETHERSCAN_API_KEY) \
			-vvvv; \
	else \
		echo "Deployment cancelled."; \
	fi

# Deploy to Arbitrum
deploy-arbitrum:
	@echo "Deploying to Arbitrum One..."
	@forge script script/DeployL1.s.sol:DeployL1 \
		--rpc-url $(ARBITRUM_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ARBISCAN_API_KEY) \
		--verifier-url https://api.arbiscan.io/api \
		-vvvv

# Deploy to Optimism
deploy-optimism:
	@echo "Deploying to Optimism..."
	@forge script script/DeployL1.s.sol:DeployL1 \
		--rpc-url $(OPTIMISM_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(OPTIMISTIC_API_KEY) \
		--verifier-url https://api-optimistic.etherscan.io/api \
		-vvvv

# Deploy to Polygon
deploy-polygon:
	@echo "Deploying to Polygon..."
	@forge script script/DeployL1.s.sol:DeployL1 \
		--rpc-url $(POLYGON_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(POLYGONSCAN_API_KEY) \
		--verifier-url https://api.polygonscan.com/api \
		-vvvv

# Deploy to Base
deploy-base:
	@echo "Deploying to Base..."
	@forge script script/DeployL1.s.sol:DeployL1 \
		--rpc-url $(BASE_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(BASESCAN_API_KEY) \
		--verifier-url https://api.basescan.org/api \
		-vvvv

# Deploy Reactive Contract (Testnet)
deploy-reactive:
	@echo "Deploying to Reactive Testnet..."
	@forge script script/DeployReactive.s.sol:DeployReactive \
		--rpc-url https://lasna-rpc.rnk.dev/ \
		--private-key $(REACTIVE_PRIVATE_KEY) \
		--broadcast \
		-vvvv

# Deploy Reactive Contract (Mainnet)
deploy-reactive-mainnet:
	@echo "Deploying to Reactive Mainnet..."
	@echo "WARNING: This will deploy to Reactive mainnet. Are you sure? [y/N]"
	@read -r response; \
	if [ "$$response" = "y" ]; then \
		forge script script/DeployReactive.s.sol:DeployReactive \
			--sig "deployToMainnet()" \
			--rpc-url https://reactive-rpc.rnk.dev/ \
			--private-key $(REACTIVE_PRIVATE_KEY) \
			--broadcast \
			-vvvv; \
	else \
		echo "Deployment cancelled."; \
	fi

# Update Reactive Contract Address on L1
update-reactive:
	@echo "Updating Reactive contract address on L1..."
	@cast send $(SUBSCRIPTION_NFT) \
		"setReactiveContract(address)" $(REACTIVE_CONTRACT) \
		--rpc-url $(L1_RPC_URL) \
		--private-key $(PRIVATE_KEY)

# Verify Contracts
verify:
	@echo "Verifying contracts..."
	@forge verify-contract \
		--chain-id $(CHAIN_ID) \
		--num-of-optimizations 200 \
		--watch \
		$(CONTRACT_ADDRESS) \
		$(CONTRACT_NAME) \
		--etherscan-api-key $(ETHERSCAN_API_KEY)

# Create deployment directories
setup:
	@mkdir -p deployments
	@echo "Created deployment directories"

# Show deployment info
info:
	@echo "=== Deployment Configuration ==="
	@echo "Network RPC URLs configured:"
	@echo "  Sepolia: $(SEPOLIA_RPC_URL)"
	@echo "  Mainnet: $(MAINNET_RPC_URL)"
	@echo "  Arbitrum: $(ARBITRUM_RPC_URL)"
	@echo "  Optimism: $(OPTIMISM_RPC_URL)"
	@echo "  Polygon: $(POLYGON_RPC_URL)"
	@echo "  Base: $(BASE_RPC_URL)"
	@echo "  Reactive Testnet: https://lasna-rpc.rnk.dev/"
	@echo "  Reactive Mainnet: https://reactive-rpc.rnk.dev/"
	@echo "================================"

# Install dependencies
install:
	@forge install
	@pnpm install

# Format code
format:
	@forge fmt

# Gas report
gas:
	@forge test --gas-report

# Coverage report
coverage:
	@forge coverage

.DEFAULT_GOAL := help