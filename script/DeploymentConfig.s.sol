// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

contract DeploymentConfig is Script {
    
    struct NetworkConfig {
        string name;
        address weth;
        address usdc;
        address usdt;
        uint64 defaultGracePeriod;
        uint64 defaultSubscriptionPeriod;
        address reactiveCallbackSender;
    }
    
    struct ReactiveConfig {
        string name;
        uint256 chainId;
        string rpcUrl;
        uint256 initialDeposit;
    }
    
    mapping(uint256 => NetworkConfig) public networkConfigs;
    mapping(uint256 => ReactiveConfig) public reactiveConfigs;
    
    constructor() {
        // Ethereum Mainnet
        networkConfigs[1] = NetworkConfig({
            name: "Ethereum Mainnet",
            weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            usdc: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            usdt: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            defaultGracePeriod: 7 days,
            defaultSubscriptionPeriod: 30 days,
            reactiveCallbackSender: 0x1D5267C1bb7D8bA68964dDF3990601BDB7902D76 // Mainnet Callback Proxy
        });
        
        // Ethereum Sepolia
        networkConfigs[11155111] = NetworkConfig({
            name: "Ethereum Sepolia",
            weth: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
            usdc: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, // AAVE USDC
            usdt: 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0, // AAVE USDT
            defaultGracePeriod: 3 days,
            defaultSubscriptionPeriod: 7 days,
            reactiveCallbackSender: 0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA // Sepolia Callback Proxy
        });
        
        // Arbitrum One
        networkConfigs[42161] = NetworkConfig({
            name: "Arbitrum One",
            weth: 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
            usdc: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831,
            usdt: 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,
            defaultGracePeriod: 7 days,
            defaultSubscriptionPeriod: 30 days,
            reactiveCallbackSender: 0x4730c58FDA9d78f60c987039aEaB7d261aAd942E // Arbitrum Callback Proxy
        });
        
        // Optimism
        networkConfigs[10] = NetworkConfig({
            name: "Optimism",
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85,
            usdt: 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58,
            defaultGracePeriod: 7 days,
            defaultSubscriptionPeriod: 30 days,
            reactiveCallbackSender: address(0)
        });
        
        // Polygon
        networkConfigs[137] = NetworkConfig({
            name: "Polygon",
            weth: 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619, // Wrapped ETH on Polygon
            usdc: 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359,
            usdt: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F,
            defaultGracePeriod: 7 days,
            defaultSubscriptionPeriod: 30 days,
            reactiveCallbackSender: address(0)
        });
        
        // Base
        networkConfigs[8453] = NetworkConfig({
            name: "Base",
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913,
            usdt: address(0), // USDT not widely used on Base
            defaultGracePeriod: 7 days,
            defaultSubscriptionPeriod: 30 days,
            reactiveCallbackSender: 0x0D3E76De6bC44309083cAAFdB49A088B8a250947 // Base Callback Proxy
        });
        
        // Local Network (Anvil/Hardhat)
        networkConfigs[31337] = NetworkConfig({
            name: "Local Network",
            weth: address(0), // Will deploy mock
            usdc: address(0), // Will deploy mock
            usdt: address(0), // Will deploy mock
            defaultGracePeriod: 1 days,
            defaultSubscriptionPeriod: 7 days,
            reactiveCallbackSender: address(0) // Will deploy mock callback proxy
        });
        
        // Reactive Network Configuration
        reactiveConfigs[0] = ReactiveConfig({
            name: "Reactive Network",
            chainId: 5318008, // Reactive mainnet chain ID
            rpcUrl: "https://reactive-rpc.rnk.dev/",
            initialDeposit: 0.1 ether // Initial REACT tokens for operations
        });
        
        // Reactive Testnet
        reactiveConfigs[1] = ReactiveConfig({
            name: "Reactive Testnet",
            chainId: 53180082, // Reactive testnet chain ID
            rpcUrl: "https://lasna-rpc.rnk.dev/",
            initialDeposit: 0.01 ether // Initial test REACT tokens
        });
    }
    
    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return networkConfigs[block.chainid];
    }
    
    function getReactiveConfig(bool testnet) public view returns (ReactiveConfig memory) {
        return testnet ? reactiveConfigs[1] : reactiveConfigs[0];
    }
    
    function setReactiveCallbackSender(uint256 chainId, address sender) external {
        networkConfigs[chainId].reactiveCallbackSender = sender;
    }
    
    // Removed salt-based deployment in favor of foundry-devops
    // DevOpsTools will track deployments across chains
    
    function isTestnet(uint256 chainId) public pure returns (bool) {
        return chainId == 11155111 || // Sepolia
               chainId == 421614 ||   // Arbitrum Sepolia
               chainId == 11155420 ||  // Optimism Sepolia
               chainId == 80002 ||    // Polygon Amoy
               chainId == 84532;      // Base Sepolia
    }
}