// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {SubscriptionReactive} from "../src/SubscriptionReactive.sol";

contract DeployReactiveMainnet is Script {
    // Mainnet contract addresses (same on all chains thanks to CREATE2)
    address constant SUBSCRIPTION_MANAGER = 0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c;
    address constant SUBSCRIPTION_NFT = 0x6D4b8BC4613dDCB98450a97b297294BacBd2DDD8;
    
    function run() external returns (address) {
        // Get target chain from environment
        uint256 targetChainId = vm.envUint("TARGET_CHAIN_ID");
        string memory chainName = getChainName(targetChainId);
        
        console.log("========================================");
        console.log("Deploying Reactive Contract for", chainName);
        console.log("Target Chain ID:", targetChainId);
        console.log("SubscriptionManager:", SUBSCRIPTION_MANAGER);
        console.log("SubscriptionNFT:", SUBSCRIPTION_NFT);
        console.log("========================================");
        
        vm.startBroadcast();
        
        // Deploy Reactive contract for this target chain
        SubscriptionReactive reactive = new SubscriptionReactive();
        console.log("SubscriptionReactive deployed at:", address(reactive));
        
        // Send initial deposit for gas
        uint256 initialDeposit = 0.01 ether; // 0.01 REACT for gas
        (bool sent, ) = address(reactive).call{value: initialDeposit}("");
        require(sent, "Failed to send initial deposit");
        console.log("Deposited initial REACT:", initialDeposit);
        
        // Initialize with mainnet addresses
        reactive.initialize(
            SUBSCRIPTION_MANAGER,
            SUBSCRIPTION_NFT,
            targetChainId
        );
        console.log("Reactive contract initialized");
        
        // Subscribe to payment events on the target chain
        reactive.subscribeToPaymentEvents(targetChainId, SUBSCRIPTION_MANAGER);
        console.log("Subscribed to payment events on", chainName);
        
        vm.stopBroadcast();
        
        console.log("\n========================================");
        console.log("DEPLOYMENT COMPLETE FOR", chainName);
        console.log("Reactive Contract:", address(reactive));
        console.log("Target Chain ID:", targetChainId);
        console.log("Monitoring Manager:", SUBSCRIPTION_MANAGER);
        console.log("========================================\n");
        
        return address(reactive);
    }
    
    function getChainName(uint256 chainId) internal pure returns (string memory) {
        if (chainId == 56) return "BSC";
        if (chainId == 8453) return "Base";
        if (chainId == 43114) return "Avalanche";
        if (chainId == 146) return "Sonic";
        return "Unknown";
    }
}