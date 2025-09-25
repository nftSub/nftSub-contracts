// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/ISubscriptionTypes.sol";
import "../interfaces/ISubscriptionNFT.sol";
import "../libraries/SubscriptionConstants.sol";
import "./MockReactiveNetwork.sol";

/**
 * @title MockSubscriptionReactive
 * @dev Mock version of SubscriptionReactive for local testing
 * Works with MockReactiveNetwork instead of the real Reactive Network
 */
contract MockSubscriptionReactive {
    using SubscriptionConstants for *;
    
    MockReactiveNetwork public immutable mockNetwork;
    
    address public subscriptionManager;
    address public subscriptionNFT;
    uint256 public targetChainId;
    
    mapping(uint256 => bool) public processedEvents;
    
    event Initialized(
        address indexed manager,
        address indexed nft,
        uint256 chainId
    );
    
    event PaymentEventProcessed(
        address indexed subscriber,
        uint256 indexed merchantId
    );
    
    event ExpiryChecked(
        uint256 timestamp,
        uint256 subscriptionsProcessed
    );
    
    constructor(address payable _mockNetwork) {
        mockNetwork = MockReactiveNetwork(_mockNetwork);
    }
    
    function initialize(
        address _subscriptionManager,
        address _subscriptionNFT,
        uint256 _targetChainId
    ) external {
        require(subscriptionManager == address(0), "Already initialized");
        
        subscriptionManager = _subscriptionManager;
        subscriptionNFT = _subscriptionNFT;
        targetChainId = _targetChainId;
        
        emit Initialized(_subscriptionManager, _subscriptionNFT, _targetChainId);
    }
    
    /**
     * @dev Subscribe to payment events from the target chain
     */
    function subscribeToPaymentEvents(
        uint256 chainId,
        address manager
    ) external returns (uint256) {
        return mockNetwork.subscribeToEvents(
            chainId,
            manager,
            SubscriptionConstants.PAYMENT_RECEIVED_TOPIC,
            bytes32(SubscriptionConstants.REACTIVE_IGNORE),
            bytes32(SubscriptionConstants.REACTIVE_IGNORE),
            bytes32(0)
        );
    }
    
    /**
     * @dev Subscribe to CRON for periodic expiry checks
     */
    function subscribeToCron(uint256 interval) external {
        mockNetwork.subscribeToCron(interval);
    }
    
    /**
     * @dev Process a payment callback from the mock network
     * Called by MockCallbackProxy
     */
    function processCallback(
        bytes32 txHash,
        uint256 blockNumber,
        uint256 logIndex,
        address subscriber,
        uint256 merchantId,
        bytes memory data
    ) external {
        // Only accept callbacks from the mock callback proxy
        require(
            msg.sender == mockNetwork.callbackProxy(),
            "Unauthorized callback"
        );
        
        // Decode additional data
        (address paymentToken, uint256 amount, uint64 expiry) = 
            abi.decode(data, (address, uint256, uint64));
        
        // Validate payment amount is not zero
        require(amount > 0, "Payment amount must be greater than zero");
        
        // Process the payment event
        uint256 eventId = uint256(keccak256(abi.encode(txHash, logIndex)));
        
        if (!processedEvents[eventId]) {
            processedEvents[eventId] = true;
            
            // Use onPaymentProcessed which handles the renewal logic correctly
            ISubscriptionNFT(subscriptionNFT).onPaymentProcessed(
                subscriber,
                merchantId,
                expiry
            );
            
            emit PaymentEventProcessed(subscriber, merchantId);
        }
    }
    
    /**
     * @dev Process CRON trigger for expiry checks
     * Called by MockCallbackProxy
     */
    function processCronTrigger(uint256 timestamp) external {
        require(
            msg.sender == mockNetwork.callbackProxy(),
            "Unauthorized callback"
        );
        
        // In a real implementation, this would check for expired subscriptions
        // For the mock, we just emit an event
        emit ExpiryChecked(timestamp, 0);
    }
    
    /**
     * @dev Pay debt to the mock network
     */
    function payDebt() external payable {
        mockNetwork.payDebt{value: msg.value}(address(this));
    }
    
    /**
     * @dev Get current debt from mock network
     */
    function getDebt() external view returns (uint256) {
        return mockNetwork.debt(address(this));
    }
    
    receive() external payable {}
}