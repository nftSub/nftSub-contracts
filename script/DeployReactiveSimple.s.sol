// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {SubscriptionReactive} from "../src/SubscriptionReactive.sol";

contract DeployReactiveSimple is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console2.log("========================================");
        console2.log("Deploying to Reactive Network");
        console2.log("Deployer:", deployer);
        console2.log("========================================");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SubscriptionReactive
        SubscriptionReactive reactive = new SubscriptionReactive();
        console2.log("SubscriptionReactive deployed:", address(reactive));
        
        vm.stopBroadcast();
        
        console2.log("\n========================================");
        console2.log("REACTIVE DEPLOYMENT COMPLETE");
        console2.log("========================================");
        console2.log("SubscriptionReactive:", address(reactive));
        console2.log("========================================");
        console2.log("\nNEXT STEPS:");
        console2.log("1. Call initialize() with destination contract addresses");
        console2.log("2. Subscribe to events from destination chains");
        console2.log("3. Subscribe to CRON for expiry checks");
        console2.log("========================================");
    }
}