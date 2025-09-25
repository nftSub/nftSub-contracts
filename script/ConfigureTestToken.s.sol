// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/interfaces/ISubscriptionManager.sol";

contract ConfigureTestToken is Script {
    address constant SUBSCRIPTION_MANAGER = 0x82b069578ae3dA9ea740D24934334208b83E530E;
    address constant TEST_TOKEN = 0x10586EBF2Ce1F3e851a8F15659cBa15b03Eb8B8A;
    
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        
        console.log("Configuring Test Token in SubscriptionManager...");
        console.log("Manager:", SUBSCRIPTION_MANAGER);
        console.log("Test Token:", TEST_TOKEN);
        
        vm.startBroadcast(deployerKey);
        
        ISubscriptionManager manager = ISubscriptionManager(SUBSCRIPTION_MANAGER);
        
        // Get deployer address
        address deployer = vm.addr(deployerKey);
        
        // Register as a merchant if not already done
        uint256 merchantId = 1; // Assuming merchant ID 1 for testing
        
        try manager.getMerchantPlan(merchantId) returns (ISubscriptionManager.MerchantPlan memory plan) {
            if (plan.payoutAddress == address(0)) {
                // Register new merchant
                merchantId = manager.registerMerchant(
                    deployer,    // Payout address (use deployer as both owner and payout)
                    30 days,     // Subscription period
                    7 days       // Grace period
                );
                console.log("Registered as merchant ID:", merchantId);
            } else {
                console.log("Using existing merchant ID:", merchantId);
                console.log("Existing payout address:", plan.payoutAddress);
            }
        } catch {
            // Register new merchant
            merchantId = manager.registerMerchant(
                deployer,    // Payout address (use deployer as both owner and payout)
                30 days,     // Subscription period
                7 days       // Grace period
            );
            console.log("Registered as merchant ID:", merchantId);
        }
        
        // Set price for test token (100 SUBTEST per subscription)
        uint256 price = 100 * 10**18; // 100 tokens with 18 decimals
        manager.setMerchantPrice(merchantId, TEST_TOKEN, price);
        console.log("Set price: 100 SUBTEST per subscription");
        
        // Also set ETH price (0.001 ETH per subscription)
        manager.setMerchantPrice(merchantId, address(0), 0.001 ether);
        console.log("Set price: 0.001 ETH per subscription");
        
        vm.stopBroadcast();
        
        console.log("\n=== CONFIGURATION COMPLETE ===");
        console.log("Merchant ID:", merchantId);
        console.log("Test Token Price:", price);
        console.log("ETH Price: 0.001 ETH");
        console.log("================================");
    }
}