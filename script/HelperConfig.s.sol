// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockReactiveNetwork.sol";
import "../src/mocks/MockSubscriptionReactive.sol";
import "../src/mocks/ReactiveTestHelper.sol";

contract HelperConfig is Script {
    NetworkConfig private _activeNetworkConfig;
    
    uint256 constant ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    
    struct NetworkConfig {
        address weth;
        address usdc;
        address usdt;
        address reactiveCallbackSender;
        address mockReactiveNetwork;
        address testHelper;
        uint256 deployerKey;
    }
    
    constructor() {
        if (block.chainid == 11155111) {
            _activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            _activeNetworkConfig = getMainnetConfig();
        } else if (block.chainid == 42161) {
            _activeNetworkConfig = getArbitrumConfig();
        } else if (block.chainid == 10) {
            _activeNetworkConfig = getOptimismConfig();
        } else if (block.chainid == 137) {
            _activeNetworkConfig = getPolygonConfig();
        } else if (block.chainid == 8453) {
            _activeNetworkConfig = getBaseConfig();
        } else {
            _activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }
    
    function activeNetworkConfig() public view returns (NetworkConfig memory) {
        return _activeNetworkConfig;
    }
    
    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14,
            usdc: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8,
            usdt: 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0,
            reactiveCallbackSender: address(0), // Will be computed
            mockReactiveNetwork: address(0),
            testHelper: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }
    
    function getMainnetConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            usdc: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            usdt: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            reactiveCallbackSender: address(0),
            mockReactiveNetwork: address(0),
            testHelper: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }
    
    function getArbitrumConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1,
            usdc: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831,
            usdt: 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,
            reactiveCallbackSender: address(0),
            mockReactiveNetwork: address(0),
            testHelper: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }
    
    function getOptimismConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85,
            usdt: 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58,
            reactiveCallbackSender: address(0),
            mockReactiveNetwork: address(0),
            testHelper: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }
    
    function getPolygonConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, // WMATIC
            usdc: 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174,
            usdt: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F,
            reactiveCallbackSender: address(0),
            mockReactiveNetwork: address(0),
            testHelper: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }
    
    function getBaseConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            weth: 0x4200000000000000000000000000000000000006,
            usdc: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913,
            usdt: address(0), // USDT not widely used on Base
            reactiveCallbackSender: address(0),
            mockReactiveNetwork: address(0),
            testHelper: address(0),
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }
    
    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // Check if already deployed
        if (_activeNetworkConfig.weth != address(0)) {
            return _activeNetworkConfig;
        }
        
        vm.startBroadcast(ANVIL_PRIVATE_KEY);
        
        // Deploy mock tokens
        MockERC20 weth = new MockERC20("Wrapped Ether", "WETH", 18);
        MockERC20 usdc = new MockERC20("USD Coin", "USDC", 6);
        MockERC20 usdt = new MockERC20("Tether USD", "USDT", 6);
        
        // Mint tokens to deployer
        address deployer = vm.addr(ANVIL_PRIVATE_KEY);
        weth.mint(deployer, 1000 * 10**18);
        usdc.mint(deployer, 1_000_000 * 10**6);
        usdt.mint(deployer, 1_000_000 * 10**6);
        
        // Deploy mock Reactive Network
        MockReactiveNetwork mockNetwork = new MockReactiveNetwork();
        
        vm.stopBroadcast();
        
        return NetworkConfig({
            weth: address(weth),
            usdc: address(usdc),
            usdt: address(usdt),
            reactiveCallbackSender: mockNetwork.callbackProxy(),
            mockReactiveNetwork: address(mockNetwork),
            testHelper: address(0), // Will be deployed separately
            deployerKey: ANVIL_PRIVATE_KEY
        });
    }
    
    function deployMockReactive(
        address manager,
        address nft
    ) external returns (address mockReactive, address testHelper) {
        require(block.chainid == LOCAL_CHAIN_ID, "Only for local testing");
        
        vm.startBroadcast(_activeNetworkConfig.deployerKey);
        
        MockReactiveNetwork mockNetwork = MockReactiveNetwork(payable(_activeNetworkConfig.mockReactiveNetwork));
        
        // Deploy MockSubscriptionReactive
        MockSubscriptionReactive reactive = new MockSubscriptionReactive(payable(address(mockNetwork)));
        reactive.initialize(manager, nft, block.chainid);
        
        // Subscribe to events
        reactive.subscribeToPaymentEvents(block.chainid, manager);
        reactive.subscribeToCron(3600);
        
        // Deploy test helper
        ReactiveTestHelper helper = new ReactiveTestHelper(
            payable(address(mockNetwork)),
            manager,
            nft,
            address(reactive)
        );
        
        vm.stopBroadcast();
        
        return (address(reactive), address(helper));
    }
}