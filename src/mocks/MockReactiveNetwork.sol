// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/ISubscriptionTypes.sol";

/**
 * @title MockReactiveNetwork
 * @dev Simulates the Reactive Network for local testing
 * This mock realistically simulates:
 * - Event subscriptions and monitoring
 * - Callback mechanism with authentication
 * - CRON functionality for periodic checks
 * - Debt tracking for gas costs
 * - Cross-chain event processing
 */
contract MockReactiveNetwork {
    
    struct Subscription {
        address subscriber;
        uint256 chainId;
        address contractAddress;
        bytes32 topic0;
        bytes32 topic1;
        bytes32 topic2;
        bytes32 topic3;
        bool active;
    }
    
    struct CronSubscription {
        address subscriber;
        uint256 interval;
        uint256 lastTriggered;
        bool active;
    }
    
    // Subscription tracking
    mapping(uint256 => Subscription) public subscriptions;
    mapping(address => uint256[]) public subscriberToSubscriptions;
    uint256 public nextSubscriptionId = 1;
    
    // CRON tracking
    mapping(address => CronSubscription) public cronSubscriptions;
    
    // Debt tracking (simulates gas costs for callbacks)
    mapping(address => uint256) public debt;
    
    // Callback proxy for authentication
    address public callbackProxy;
    
    // Events for debugging
    event EventSubscribed(
        uint256 indexed subscriptionId,
        address indexed subscriber,
        uint256 chainId,
        address contractAddress,
        bytes32 topic0
    );
    
    event CronSubscribed(
        address indexed subscriber,
        uint256 interval
    );
    
    event CallbackTriggered(
        address indexed target,
        bytes payload,
        uint256 gasUsed
    );
    
    event EventProcessed(
        uint256 indexed subscriptionId,
        bytes32 indexed txHash,
        uint256 blockNumber
    );
    
    modifier onlyCallbackProxy() {
        require(msg.sender == callbackProxy, "Only callback proxy");
        _;
    }
    
    constructor() {
        // Deploy a mock callback proxy
        callbackProxy = address(new MockCallbackProxy(address(this)));
    }
    
    /**
     * @dev Subscribe to events on a destination chain
     * Simulates the reactive network's event subscription
     */
    function subscribeToEvents(
        uint256 chainId,
        address contractAddress,
        bytes32 topic0,
        bytes32 topic1,
        bytes32 topic2,
        bytes32 topic3
    ) external returns (uint256) {
        uint256 subscriptionId = nextSubscriptionId++;
        
        subscriptions[subscriptionId] = Subscription({
            subscriber: msg.sender,
            chainId: chainId,
            contractAddress: contractAddress,
            topic0: topic0,
            topic1: topic1,
            topic2: topic2,
            topic3: topic3,
            active: true
        });
        
        subscriberToSubscriptions[msg.sender].push(subscriptionId);
        
        emit EventSubscribed(
            subscriptionId,
            msg.sender,
            chainId,
            contractAddress,
            topic0
        );
        
        return subscriptionId;
    }
    
    /**
     * @dev Subscribe to CRON events for periodic triggers
     */
    function subscribeToCron(uint256 interval) external {
        cronSubscriptions[msg.sender] = CronSubscription({
            subscriber: msg.sender,
            interval: interval,
            lastTriggered: block.timestamp,
            active: true
        });
        
        emit CronSubscribed(msg.sender, interval);
    }
    
    /**
     * @dev Simulate processing an event from the monitored chain
     * This would be called by test helpers to trigger callbacks
     */
    function simulateEvent(
        uint256 subscriptionId,
        bytes32 txHash,
        uint256 blockNumber,
        uint256 logIndex,
        address indexed_1,
        uint256 indexed_2,
        bytes memory data
    ) external {
        Subscription memory sub = subscriptions[subscriptionId];
        require(sub.active, "Subscription not active");
        
        // Track gas for debt calculation
        uint256 gasStart = gasleft();
        
        // Prepare the callback data (simulating LogRecord structure)
        bytes memory callbackData = abi.encodeWithSignature(
            "processCallback(bytes32,uint256,uint256,address,uint256,bytes)",
            txHash,
            blockNumber,
            logIndex,
            indexed_1,
            indexed_2,
            data
        );
        
        // Use the callback proxy to authenticate the call
        MockCallbackProxy(callbackProxy).forwardCallback(
            sub.subscriber,
            callbackData
        );
        
        uint256 gasUsed = gasStart - gasleft();
        
        // Add to debt (simulate gas cost at 1 gwei per gas unit)
        debt[sub.subscriber] += gasUsed * 1 gwei;
        
        emit CallbackTriggered(sub.subscriber, callbackData, gasUsed);
        emit EventProcessed(subscriptionId, txHash, blockNumber);
    }
    
    /**
     * @dev Trigger a CRON event for a subscriber
     * Tests can call this to simulate time passing
     */
    function triggerCron(address subscriber) external {
        CronSubscription storage cron = cronSubscriptions[subscriber];
        require(cron.active, "No active CRON subscription");
        require(
            block.timestamp >= cron.lastTriggered + cron.interval,
            "Too early for CRON trigger"
        );
        
        cron.lastTriggered = block.timestamp;
        
        // Track gas for debt
        uint256 gasStart = gasleft();
        
        // Trigger CRON callback
        bytes memory cronData = abi.encodeWithSignature(
            "processCronTrigger(uint256)",
            block.timestamp
        );
        
        MockCallbackProxy(callbackProxy).forwardCallback(
            subscriber,
            cronData
        );
        
        uint256 gasUsed = gasStart - gasleft();
        debt[subscriber] += gasUsed * 1 gwei;
        
        emit CallbackTriggered(subscriber, cronData, gasUsed);
    }
    
    /**
     * @dev Pay off debt (simulates covering callback gas costs)
     */
    function payDebt(address debtor) external payable {
        uint256 debtAmount = debt[debtor];
        require(msg.value >= debtAmount, "Insufficient payment");
        
        debt[debtor] = 0;
        
        // Return excess payment
        if (msg.value > debtAmount) {
            payable(msg.sender).transfer(msg.value - debtAmount);
        }
    }
    
    /**
     * @dev Get all subscriptions for a subscriber
     */
    function getSubscriptions(address subscriber) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return subscriberToSubscriptions[subscriber];
    }
    
    /**
     * @dev Check if ready for CRON trigger
     */
    function canTriggerCron(address subscriber) external view returns (bool) {
        CronSubscription memory cron = cronSubscriptions[subscriber];
        return cron.active && 
               block.timestamp >= cron.lastTriggered + cron.interval;
    }
    
    /**
     * @dev Unsubscribe from events
     */
    function unsubscribe(uint256 subscriptionId) external {
        require(
            subscriptions[subscriptionId].subscriber == msg.sender,
            "Not subscription owner"
        );
        subscriptions[subscriptionId].active = false;
    }
    
    /**
     * @dev Unsubscribe from CRON
     */
    function unsubscribeCron() external {
        cronSubscriptions[msg.sender].active = false;
    }
    
    receive() external payable {}
}

/**
 * @title MockCallbackProxy
 * @dev Simulates the Reactive Network's callback proxy
 * Authenticates and forwards callbacks to destination contracts
 */
contract MockCallbackProxy {
    address public immutable reactiveNetwork;
    
    event CallbackForwarded(
        address indexed target,
        bytes data,
        bool success
    );
    
    constructor(address _reactiveNetwork) {
        reactiveNetwork = _reactiveNetwork;
    }
    
    /**
     * @dev Forward an authenticated callback to the target contract
     * Only the reactive network can call this
     */
    function forwardCallback(
        address target,
        bytes memory data
    ) external returns (bool success) {
        require(msg.sender == reactiveNetwork, "Only reactive network");
        
        // Forward the callback with authentication
        (success, ) = target.call(data);
        
        emit CallbackForwarded(target, data, success);
        
        return success;
    }
    
    /**
     * @dev Simulate checking if a callback is authentic
     * In the real system, this would verify the origin
     */
    function isAuthenticCallback() external view returns (bool) {
        // In production, this checks tx.origin or other authentication
        // For testing, we just check if called via this proxy
        return true;
    }
}