// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/SubscriptionManager.sol";
import "../src/SubscriptionNFT.sol";
import "./HelperConfig.s.sol";

contract DeployL1 is Script {
    
    function run() external returns (
        SubscriptionManager manager,
        SubscriptionNFT nft,
        address reactiveCallbackSender
    ) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.activeNetworkConfig();
        
        console.log("Deploying to Chain ID:", block.chainid);
        console.log("Deployer:", vm.addr(config.deployerKey));
        
        // Get or predict reactive callback sender
        reactiveCallbackSender = config.reactiveCallbackSender;
        if (reactiveCallbackSender == address(0) && block.chainid != 31337) {
            // Predict address for production networks
            address deployer = vm.addr(config.deployerKey);
            reactiveCallbackSender = vm.computeCreateAddress(
                deployer, 
                vm.getNonce(deployer) + 100
            );
            console.log("Predicted Reactive callback:", reactiveCallbackSender);
        }
        
        vm.startBroadcast(config.deployerKey);
        
        // Deploy SubscriptionManager
        manager = new SubscriptionManager();
        console.log("SubscriptionManager:", address(manager));
        
        // Deploy SubscriptionNFT
        string memory nftUri = string(abi.encodePacked(
            "https://api.subscription-nft.io/metadata/",
            vm.toString(block.chainid),
            "/{id}"
        ));
        
        nft = new SubscriptionNFT(
            nftUri,
            address(manager),
            reactiveCallbackSender
        );
        console.log("SubscriptionNFT:", address(nft));
        
        // Configure manager
        manager.setSubscriptionNFT(address(nft));
        
        // Setup token support
        // NOTE: setSupportedToken method needs to be added to SubscriptionManager
        // if (config.weth != address(0)) {
        //     manager.setSupportedToken(config.weth, true);
        //     console.log("WETH supported:", config.weth);
        // }
        // if (config.usdc != address(0)) {
        //     manager.setSupportedToken(config.usdc, true);
        //     console.log("USDC supported:", config.usdc);
        // }
        // if (config.usdt != address(0)) {
        //     manager.setSupportedToken(config.usdt, true);
        //     console.log("USDT supported:", config.usdt);
        // }
        
        vm.stopBroadcast();
        
        // Deploy mock reactive if on local
        if (block.chainid == 31337) {
            console.log("\n=== DEPLOYING MOCK REACTIVE ===");
            (address mockReactive, address testHelper) = helperConfig.deployMockReactive(
                address(manager),
                address(nft)
            );
            
            // Grant role to mock reactive
            vm.startBroadcast(config.deployerKey);
            bytes32 MANAGER_ROLE = keccak256("MANAGER_ROLE");
            nft.grantRole(MANAGER_ROLE, mockReactive);
            vm.stopBroadcast();
            
            console.log("MockReactive:", mockReactive);
            console.log("TestHelper:", testHelper);
            reactiveCallbackSender = mockReactive;
        }
        
        // Log deployment info instead of writing to file
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("Chain ID:", block.chainid);
        console.log("SubscriptionManager:", address(manager));
        console.log("SubscriptionNFT:", address(nft));
        console.log("Reactive/Callback Sender:", reactiveCallbackSender);
        console.log("===========================");
        
        return (manager, nft, reactiveCallbackSender);
    }
}