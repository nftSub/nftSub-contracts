// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/mocks/MockERC20.sol";

contract DeployTestToken is Script {
    function run() external returns (MockERC20 token) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        
        console.log("Deploying Test Token to Sepolia...");
        console.log("Deployer:", deployer);
        
        vm.startBroadcast(deployerKey);
        
        // Deploy test token with 18 decimals
        token = new MockERC20("Subscription Test Token", "SUBTEST", 18);
        console.log("Test Token deployed at:", address(token));
        
        // Mint initial supply to deployer (1 million tokens)
        token.mint(deployer, 1_000_000 * 10**18);
        console.log("Minted 1,000,000 SUBTEST to deployer");
        
        vm.stopBroadcast();
        
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("Token Address:", address(token));
        console.log("Token Name:", token.name());
        console.log("Token Symbol:", token.symbol());
        console.log("Token Decimals:", token.decimals());
        console.log("===========================");
        
        return token;
    }
}