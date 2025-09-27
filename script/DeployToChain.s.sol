// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {SubscriptionManager} from "../src/SubscriptionManager.sol";
import {SubscriptionNFT} from "../src/SubscriptionNFT.sol";
import {MainnetConfig} from "./config/MainnetConfig.sol";

contract DeployToChain is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Get chain ID from environment or use current
        uint256 chainId = block.chainid;
        
        console2.log("========================================");
        console2.log("Deploying to Chain ID:", chainId);
        console2.log("Deployer:", deployer);
        console2.log("Balance:", deployer.balance / 1e18, "native tokens");
        console2.log("========================================");
        
        // Get callback proxy for this chain
        address callbackProxy = getCallbackProxy(chainId);
        require(callbackProxy != address(0), "Unsupported chain");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SubscriptionManager first
        SubscriptionManager manager = new SubscriptionManager();
        console2.log("SubscriptionManager deployed:", address(manager));
        
        // Construct base URI
        string memory baseURI = string.concat(
            "https://nft-sub.vercel.app/api/metadata/",
            vm.toString(chainId),
            "/{id}"
        );
        
        // Deploy SubscriptionNFT with proper constructor params
        SubscriptionNFT nft = new SubscriptionNFT(
            baseURI,
            address(manager),
            callbackProxy
        );
        console2.log("SubscriptionNFT deployed:", address(nft));
        console2.log("Base URI:", baseURI);
        
        // Set NFT address in manager
        manager.setSubscriptionNFT(address(nft));
        console2.log("Manager configured with NFT");
        
        vm.stopBroadcast();
        
        console2.log("\n========================================");
        console2.log("DEPLOYMENT COMPLETE");
        console2.log("========================================");
        console2.log("Chain ID:", chainId);
        console2.log("SubscriptionManager:", address(manager));
        console2.log("SubscriptionNFT:", address(nft));
        console2.log("========================================");
    }
    
    function getCallbackProxy(uint256 chainId) internal pure returns (address) {
        if (chainId == 56) return 0xdb81A196A0dF9Ef974C9430495a09B6d535fAc48; // BSC
        if (chainId == 8453) return 0x0D3E76De6bC44309083cAAFdB49A088B8a250947; // Base
        if (chainId == 43114) return 0x934Ea75496562D4e83E80865c33dbA600644fCDa; // Avalanche
        if (chainId == 146) return 0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4; // Sonic
        if (chainId == 11155111) return 0x33bFb5E7232F14D835E0839c0FD4ce8d44023d8a; // Sepolia (for testing)
        return address(0);
    }
}