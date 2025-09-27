// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {SubscriptionReactive} from "../src/SubscriptionReactive.sol";

contract AddCronSubscription is Script {
    // Reactive contract address on mainnet
    address payable constant REACTIVE_CONTRACT = payable(0x99ad42b29a7a99Ee4552cf6dc36dc4d44d8b0A2c);
    
    function run() external {
        console.log("========================================");
        console.log("Adding CRON Subscription for Expiry Checks");
        console.log("Reactive Contract:", REACTIVE_CONTRACT);
        console.log("========================================");
        
        vm.startBroadcast();
        
        SubscriptionReactive reactive = SubscriptionReactive(REACTIVE_CONTRACT);
        
        // Subscribe to CRON for daily expiry checks (86400 seconds = 24 hours)
        uint256 interval = 86400;
        reactive.subscribeToCron(interval);
        
        console.log("CRON subscription added with interval:", interval, "seconds (24 hours)");
        
        vm.stopBroadcast();
        
        console.log("========================================");
        console.log("CRON SUBSCRIPTION COMPLETE");
        console.log("Expiry checks will run every 24 hours");
        console.log("========================================");
    }
}