// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "./DeployL1.s.sol";
import "./DeployReactive.s.sol";

contract Deploy is Script {
    
    DeployL1 deployL1;
    DeployReactive deployReactive;
    
    function run() external {
        console.log("\n==============================================");
        console.log("    SUBSCRIPTION NFT FULL DEPLOYMENT");
        console.log("==============================================\n");
        
        deployL1 = new DeployL1();
        deployReactive = new DeployReactive();
        
        // Step 1: Deploy L1 contracts
        console.log("STEP 1: Deploying L1 Contracts...");
        console.log("----------------------------------");
        
        (
            SubscriptionManager manager,
            SubscriptionNFT nft,
            address predictedReactive
        ) = deployL1.run();
        
        // Step 2: Deploy Reactive contract
        console.log("\nSTEP 2: Deploying Reactive Contract...");
        console.log("--------------------------------------");
        console.log("NOTE: Set these environment variables:");
        console.log("  TARGET_CHAIN_ID=", block.chainid);
        console.log("  SUBSCRIPTION_MANAGER=", address(manager));
        console.log("  SUBSCRIPTION_NFT=", address(nft));
        console.log("  REACTIVE_PRIVATE_KEY=<your_reactive_key>");
        console.log("\nThen run: forge script script/DeployReactive.s.sol:DeployReactive --broadcast");
        
        // Step 3: Update L1 contracts
        console.log("\nSTEP 3: Update L1 Contracts...");
        console.log("-------------------------------");
        console.log("After deploying to Reactive Network, update the NFT contract:");
        console.log("  cast send", address(nft));
        console.log("    'setReactiveContract(address)' <REACTIVE_ADDRESS>");
        console.log("    --rpc-url <L1_RPC> --private-key <KEY>");
        
        console.log("\n==============================================");
        console.log("    DEPLOYMENT PROCESS COMPLETE");
        console.log("==============================================\n");
    }
    
    // Deploy to specific networks
    function deployToSepolia() external {
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        this.run();
    }
    
    function deployToMainnet() external {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        this.run();
    }
    
    function deployToArbitrum() external {
        vm.createSelectFork(vm.envString("ARBITRUM_RPC_URL"));
        this.run();
    }
    
    function deployToOptimism() external {
        vm.createSelectFork(vm.envString("OPTIMISM_RPC_URL"));
        this.run();
    }
    
    function deployToPolygon() external {
        vm.createSelectFork(vm.envString("POLYGON_RPC_URL"));
        this.run();
    }
    
    function deployToBase() external {
        vm.createSelectFork(vm.envString("BASE_RPC_URL"));
        this.run();
    }
}