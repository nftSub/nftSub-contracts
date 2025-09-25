// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "reactive-lib/src/abstract-base/AbstractReactive.sol";
import "reactive-lib/src/interfaces/ISubscriptionService.sol";
import "./interfaces/ISubscriptionReactive.sol";
import "./libraries/SubscriptionConstants.sol";

contract SubscriptionReactive is ISubscriptionReactive, AbstractReactive {
    using SubscriptionConstants for *;
    
    struct EventSubscription {
        uint256 chain_id;
        address _contract;
        uint256 topic_0;
        uint256 topic_1;
        uint256 topic_2;
        uint256 topic_3;
    }
    
    struct Config {
        address subscriptionManager;
        address subscriptionNFT;
        uint256 destinationChainId;
        uint64 callbackGasLimit;
    }
    
    Config private config;
    bool private paused;
    
    mapping(address => mapping(uint256 => uint64)) private trackedExpirations;
    
    address[] private expiringUsers;
    uint256[] private expiringMerchantIds;
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    receive() external payable override(AbstractPayer, IPayer) {}
    
    function initialize(
        address subscriptionManager,
        address subscriptionNFT,
        uint256 destinationChainId
    ) external override rnOnly {
        require(config.subscriptionManager == address(0), "Already initialized");
        
        config = Config({
            subscriptionManager: subscriptionManager,
            subscriptionNFT: subscriptionNFT,
            destinationChainId: destinationChainId,
            callbackGasLimit: SubscriptionConstants.DEFAULT_CALLBACK_GAS_LIMIT
        });
    }
    
    function subscribeToPaymentEvents(
        uint256 chainId,
        address contractAddress
    ) external override rnOnly {
        ISubscriptionService(service).subscribe(
            chainId,
            contractAddress,
            uint256(SubscriptionConstants.PAYMENT_RECEIVED_TOPIC),
            SubscriptionConstants.REACTIVE_IGNORE,
            SubscriptionConstants.REACTIVE_IGNORE,
            SubscriptionConstants.REACTIVE_IGNORE
        );
    }
    
    function subscribeToCron(uint256 interval) external override rnOnly {
        ISubscriptionService(service).subscribe(
            0, // CRON subscription
            address(0),
            interval,
            0,
            0,
            0
        );
    }
    
    function react(LogRecord calldata log) external override vmOnly whenNotPaused {
        if (log.topic_0 == uint256(SubscriptionConstants.PAYMENT_RECEIVED_TOPIC)) {
            _processPaymentEvent(log);
        } else if (log.chain_id == 0 && log._contract == address(0)) {
            // CRON event
            _processCronEvent();
        }
    }
    
    function _processPaymentEvent(LogRecord calldata log) private {
        (
            address user,
            uint256 merchantId,
            ,
            ,
            ,
            uint64 period
        ) = abi.decode(log.data, (address, uint256, address, uint256, uint256, uint64));
        
        uint64 currentExpiry = trackedExpirations[user][merchantId];
        uint64 newExpiry;
        
        if (currentExpiry > uint64(block.timestamp)) {
            newExpiry = currentExpiry + period;
        } else {
            newExpiry = uint64(block.timestamp) + period;
        }
        
        trackedExpirations[user][merchantId] = newExpiry;
        
        bytes memory payload = abi.encodeWithSignature(
            "onPaymentProcessed(address,uint256,uint64)",
            user,
            merchantId,
            newExpiry
        );
        
        emit Callback(
            config.destinationChainId,
            config.subscriptionNFT,
            config.callbackGasLimit,
            payload
        );
    }
    
    function _processCronEvent() private {
        uint256 currentTime = block.timestamp;
        uint256 maxBatch = 50;
        
        delete expiringUsers;
        delete expiringMerchantIds;
        
        // Check tracked subscriptions for expiry
        // This implementation requires off-chain indexing for production scale
        // The CRON event triggers periodic cleanup
        
        if (expiringUsers.length > 0 && expiringUsers.length <= maxBatch) {
            bytes memory payload = abi.encodeWithSignature(
                "processBatchExpiry(address[],uint256[])",
                expiringUsers,
                expiringMerchantIds
            );
            
            emit Callback(
                config.destinationChainId,
                config.subscriptionNFT,
                config.callbackGasLimit,
                payload
            );
        }
    }
    
    function updateSubscriptionState(
        address user,
        uint256 merchantId,
        uint64 expiresAt
    ) external override {
        trackedExpirations[user][merchantId] = expiresAt;
    }
    
    function getTrackedExpiration(
        address user,
        uint256 merchantId
    ) external view override returns (uint64) {
        return trackedExpirations[user][merchantId];
    }
    
    function getExpiringSubscriptions(
        uint64, // beforeTimestamp - will be used in production
        uint256 // limit - will be used in production
    ) external pure override returns (
        address[] memory users,
        uint256[] memory merchantIds
    ) {
        // TODO: Implement proper iteration in production
        // Would filter trackedExpirations where expiresAt < beforeTimestamp
        users = new address[](0);
        merchantIds = new uint256[](0);
    }
    
    function pause() external override rnOnly {
        paused = true;
    }
    
    function resume() external override rnOnly {
        paused = false;
    }
    
    // coverDebt() is inherited from AbstractPayer through AbstractReactive
    // No need to override as it's not virtual
    
    function getDebt() external view override returns (uint256) {
        // Returns accumulated debt from RVM callbacks
        // AbstractPayer tracks this via vendor.debt(address(this))
        if (address(vendor) != address(0)) {
            return vendor.debt(address(this));
        }
        return 0;
    }
    
    function depositForOperations() external payable override {
        // Accepts deposits for future operations
    }
    
    function updateCallbackGasLimit(uint64 newLimit) external override rnOnly {
        config.callbackGasLimit = newLimit;
    }
    
    function emergencyWithdraw() external override rnOnly {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");
        
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}