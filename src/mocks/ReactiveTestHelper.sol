// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockReactiveNetwork.sol";
import "../interfaces/ISubscriptionManager.sol";
import "../libraries/SubscriptionConstants.sol";

/**
 * @title ReactiveTestHelper
 * @dev Helper contract for testing the subscription system with mock reactive network
 * Provides convenient functions to simulate various scenarios
 */
contract ReactiveTestHelper {
    using SubscriptionConstants for *;
    
    MockReactiveNetwork public mockNetwork;
    address public subscriptionManager;
    address public subscriptionNFT;
    address public mockReactive;
    
    // Track subscription IDs for testing
    uint256 public paymentSubscriptionId;
    
    event PaymentSimulated(
        address indexed subscriber,
        uint256 indexed merchantId,
        uint256 amount
    );
    
    event CronTriggered(uint256 timestamp);
    
    constructor(
        address payable _mockNetwork,
        address _subscriptionManager,
        address _subscriptionNFT,
        address _mockReactive
    ) {
        mockNetwork = MockReactiveNetwork(_mockNetwork);
        subscriptionManager = _subscriptionManager;
        subscriptionNFT = _subscriptionNFT;
        mockReactive = _mockReactive;
    }
    
    /**
     * @dev Simulate a payment event from L1
     * This triggers the mock reactive network to call back to the subscription NFT
     */
    function simulatePaymentEvent(
        address subscriber,
        uint256 merchantId,
        address paymentToken,
        uint256 amount,
        uint64 expiry
    ) external {
        // Create event data matching PaymentReceived event structure
        bytes memory eventData = abi.encode(
            paymentToken,
            amount,
            expiry
        );
        
        // Simulate the event through the mock network
        mockNetwork.simulateEvent(
            paymentSubscriptionId,
            keccak256(abi.encode(block.timestamp, subscriber, merchantId)), // Mock tx hash
            block.number,
            0, // log index
            subscriber,
            merchantId,
            eventData
        );
        
        emit PaymentSimulated(subscriber, merchantId, amount);
    }
    
    /**
     * @dev Set up payment event subscription
     * Call this after deploying to establish the subscription
     */
    function setupPaymentSubscription(uint256 subscriptionId) external {
        paymentSubscriptionId = subscriptionId;
    }
    
    /**
     * @dev Trigger a CRON event for expiry checks
     */
    function triggerExpiryCheck() external {
        mockNetwork.triggerCron(mockReactive);
        emit CronTriggered(block.timestamp);
    }
    
    /**
     * @dev Simulate time passing for CRON tests
     * Note: This requires using vm.warp in Foundry tests
     */
    function canTriggerCron() external view returns (bool) {
        return mockNetwork.canTriggerCron(mockReactive);
    }
    
    /**
     * @dev Helper to create a complete subscription flow
     * Combines payment processing and NFT minting
     */
    function createSubscriptionFlow(
        address subscriber,
        uint256 merchantId,
        address paymentToken,
        uint256 amount,
        uint64 subscriptionPeriod
    ) external payable {
        // First, ensure merchant exists in the manager
        // (In real tests, merchant should be created first)
        
        // Calculate expiry
        uint64 expiry = uint64(block.timestamp) + subscriptionPeriod;
        
        // Simulate the payment event
        this.simulatePaymentEvent(
            subscriber,
            merchantId,
            paymentToken,
            amount,
            expiry
        );
    }
    
    /**
     * @dev Check subscription status
     */
    function getSubscriptionStatus(address subscriber, uint256 merchantId) 
        external 
        view 
        returns (bool active, uint64 expiry) 
    {
        // This would interface with the NFT contract
        // For testing purposes, we'll need to add this to the NFT interface
        return (false, 0); // Placeholder
    }
    
    /**
     * @dev Simulate multiple payments in batch
     */
    function batchSimulatePayments(
        address[] memory subscribers,
        uint256[] memory merchantIds,
        uint256[] memory amounts,
        uint64[] memory expiries
    ) external {
        require(
            subscribers.length == merchantIds.length &&
            subscribers.length == amounts.length &&
            subscribers.length == expiries.length,
            "Array length mismatch"
        );
        
        for (uint i = 0; i < subscribers.length; i++) {
            this.simulatePaymentEvent(
                subscribers[i],
                merchantIds[i],
                address(0), // ETH payment
                amounts[i],
                expiries[i]
            );
        }
    }
    
    /**
     * @dev Get mock network debt for testing gas costs
     */
    function getReactiveDebt() external view returns (uint256) {
        return mockNetwork.debt(mockReactive);
    }
    
    /**
     * @dev Pay reactive debt for testing
     */
    function payReactiveDebt() external payable {
        mockNetwork.payDebt{value: msg.value}(mockReactive);
    }
    
    /**
     * @dev Helper to advance time and trigger cron
     * For use with Foundry's vm.warp
     */
    function advanceTimeAndTriggerCron(uint256 timeToAdvance) external {
        // Note: vm.warp must be called in the test file
        // This just triggers after time is advanced
        if (mockNetwork.canTriggerCron(mockReactive)) {
            mockNetwork.triggerCron(mockReactive);
            emit CronTriggered(block.timestamp);
        }
    }
}