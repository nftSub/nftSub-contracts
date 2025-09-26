// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library MainnetConfig {
    // Chains we're deploying to (excluding Ethereum)
    struct ChainConfig {
        uint256 chainId;
        string name;
        string rpcUrl;
        address callbackProxy;
        uint256 gasPrice; // in gwei
    }
    
    // Reactive Network Mainnet
    address constant REACTIVE_CALLBACK_PROXY = 0x0000000000000000000000000000000000fffFfF;
    string constant REACTIVE_RPC = "https://mainnet-rpc.rnk.dev/";
    uint256 constant REACTIVE_CHAIN_ID = 1597;
    
    // Destination chains configuration
    function getBSC() internal pure returns (ChainConfig memory) {
        return ChainConfig({
            chainId: 56,
            name: "BSC",
            rpcUrl: "https://bsc-dataseed1.binance.org",
            callbackProxy: 0xdb81A196A0dF9Ef974C9430495a09B6d535fAc48,
            gasPrice: 3 // 3 gwei typical for BSC
        });
    }
    
    function getBase() internal pure returns (ChainConfig memory) {
        return ChainConfig({
            chainId: 8453,
            name: "Base",
            rpcUrl: "https://mainnet.base.org",
            callbackProxy: 0x0D3E76De6bC44309083cAAFdB49A088B8a250947,
            gasPrice: 1 // Base has low gas
        });
    }
    
    function getAvalanche() internal pure returns (ChainConfig memory) {
        return ChainConfig({
            chainId: 43114,
            name: "Avalanche C-Chain",
            rpcUrl: "https://api.avax.network/ext/bc/C/rpc",
            callbackProxy: 0x934Ea75496562D4e83E80865c33dbA600644fCDa,
            gasPrice: 25 // 25 nAVAX typical
        });
    }
    
    function getSonic() internal pure returns (ChainConfig memory) {
        return ChainConfig({
            chainId: 146,
            name: "Sonic",
            rpcUrl: "https://rpc.soniclabs.com",
            callbackProxy: 0x9299472a6399fd1027ebf067571eb3e3d7837fc4,
            gasPrice: 100 // Adjust based on Sonic network
        });
    }
    
    // Token addresses on different chains (USDC/USDT)
    struct TokenConfig {
        address usdc;
        address usdt;
        address weth; // Wrapped native token
    }
    
    function getTokens(uint256 chainId) internal pure returns (TokenConfig memory) {
        if (chainId == 56) { // BSC
            return TokenConfig({
                usdc: 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d, // USDC on BSC
                usdt: 0x55d398326f99059fF775485246999027B3197955, // USDT on BSC
                weth: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c  // WBNB
            });
        } else if (chainId == 8453) { // Base
            return TokenConfig({
                usdc: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, // USDC on Base
                usdt: address(0), // USDT not common on Base
                weth: 0x4200000000000000000000000000000000000006  // WETH on Base
            });
        } else if (chainId == 43114) { // Avalanche
            return TokenConfig({
                usdc: 0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E, // USDC on Avalanche
                usdt: 0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7, // USDT on Avalanche
                weth: 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7  // WAVAX
            });
        } else if (chainId == 146) { // Sonic
            return TokenConfig({
                usdc: address(0), // Need Sonic USDC address
                usdt: address(0), // Need Sonic USDT address
                weth: address(0)  // Need Sonic wrapped token
            });
        }
        
        return TokenConfig({
            usdc: address(0),
            usdt: address(0),
            weth: address(0)
        });
    }
    
    // Deployment cost estimates (in native token)
    function getDeploymentCost(uint256 chainId) internal pure returns (uint256) {
        if (chainId == 56) return 0.01 ether; // ~$3 on BSC
        if (chainId == 8453) return 0.001 ether; // ~$3 on Base
        if (chainId == 42161) return 0.001 ether; // ~$3 on Arbitrum
        if (chainId == 43114) return 0.1 ether; // ~$3 on Avalanche
        if (chainId == 146) return 1 ether; // Adjust for Sonic
        if (chainId == 1597) return 0.1 ether; // Reactive Network
        return 0.01 ether; // Default
    }
}