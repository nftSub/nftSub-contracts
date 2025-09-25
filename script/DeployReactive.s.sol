// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/SubscriptionReactive.sol";
import "./DeploymentConfig.s.sol";

contract DeployReactive is Script, DeploymentConfig {
    
    function run() external returns (SubscriptionReactive reactive) {
        return deployReactive(true); // Default to testnet
    }
    
    function deployReactive(bool useTestnet) public returns (SubscriptionReactive reactive) {
        ReactiveConfig memory config = getReactiveConfig(useTestnet);
        
        console.log("Deploying to Reactive Network");
        console.log("Network:", config.name);
        console.log("RPC URL:", config.rpcUrl);
        
        // Load deployment addresses from L1
        uint256 targetChainId = vm.envUint("TARGET_CHAIN_ID");
        address subscriptionManager = vm.envAddress("SUBSCRIPTION_MANAGER");
        address subscriptionNFT = vm.envAddress("SUBSCRIPTION_NFT");
        
        console.log("Target Chain ID:", targetChainId);
        console.log("SubscriptionManager:", subscriptionManager);
        console.log("SubscriptionNFT:", subscriptionNFT);
        
        uint256 deployerPrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        console.log("Initial deposit:", config.initialDeposit);
        
        // Switch to Reactive Network RPC
        vm.createSelectFork(config.rpcUrl);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SubscriptionReactive
        reactive = new SubscriptionReactive();
        console.log("SubscriptionReactive deployed at:", address(reactive));
        
        // Send initial REACT deposit for operations
        if (config.initialDeposit > 0) {
            (bool success,) = address(reactive).call{value: config.initialDeposit}("");
            require(success, "Failed to deposit initial REACT");
            console.log("Deposited initial REACT:", config.initialDeposit);
        }
        
        // Initialize the reactive contract
        reactive.initialize(
            subscriptionManager,
            subscriptionNFT,
            targetChainId
        );
        console.log("Reactive contract initialized");
        
        // Subscribe to payment events from the destination chain
        reactive.subscribeToPaymentEvents(
            targetChainId,
            subscriptionManager
        );
        console.log("Subscribed to payment events on chain", targetChainId);
        
        // Subscribe to CRON for periodic expiry checks (every hour)
        // CRON interval is 3600 for hourly checks
        reactive.subscribeToCron(3600);
        console.log("Subscribed to hourly CRON events");
        
        vm.stopBroadcast();
        
        // Log deployment summary
        console.log("\n=== REACTIVE DEPLOYMENT SUMMARY ===");
        console.log("Network:", config.name);
        console.log("SubscriptionReactive:", address(reactive));
        console.log("Monitoring Chain:", targetChainId);
        console.log("SubscriptionManager:", subscriptionManager);
        console.log("SubscriptionNFT:", subscriptionNFT);
        console.log("Initial Deposit:", config.initialDeposit);
        console.log("====================================\n");
        
        // Save deployment info
        string memory deploymentInfo = string(abi.encodePacked(
            '{"network":"',
            config.name,
            '","reactive":"',
            vm.toString(address(reactive)),
            '","targetChainId":',
            vm.toString(targetChainId),
            ',"subscriptionManager":"',
            vm.toString(subscriptionManager),
            '","subscriptionNFT":"',
            vm.toString(subscriptionNFT),
            '"}'
        ));
        
        string memory filename = "./deployments/reactive-deployment.json";
        vm.writeFile(filename, deploymentInfo);
        console.log("Deployment info saved to:", filename);
        
        // Now update the L1 contracts with the reactive address
        console.log("\nNOTE: Update SubscriptionNFT on L1 with Reactive address:");
        console.log("  Run: cast send", subscriptionNFT);
        console.log("       'setReactiveContract(address)'", address(reactive));
        console.log("       --rpc-url <L1_RPC> --private-key <KEY>\n");
        
        return reactive;
    }
    
    function deployToMainnet() external returns (SubscriptionReactive) {
        return deployReactive(false);
    }
    
    function deployToTestnet() external returns (SubscriptionReactive) {
        return deployReactive(true);
    }
}