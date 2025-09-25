// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "reactive-lib/src/abstract-base/AbstractCallback.sol";
import "./interfaces/ISubscriptionNFT.sol";

contract SubscriptionNFT is ISubscriptionNFT, ERC1155, AccessControl, ReentrancyGuard, AbstractCallback {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant REACTIVE_ROLE = keccak256("REACTIVE_ROLE");
    
    mapping(address => mapping(uint256 => SubscriptionStatus)) private subscriptions;
    mapping(uint256 => uint64) private merchantGracePeriods;
    
    address public subscriptionManager;
    address public reactiveContract;
    
    constructor(
        string memory uri,
        address _manager,
        address _callbackSender
    ) ERC1155(uri) AbstractCallback(_callbackSender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, _manager);
        subscriptionManager = _manager;
    }
    
    function setReactiveContract(address _reactive) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(reactiveContract == address(0), "Already set");
        reactiveContract = _reactive;
        _grantRole(REACTIVE_ROLE, _reactive);
    }
    
    function setMerchantGracePeriod(uint256 merchantId, uint64 gracePeriod) 
        external onlyRole(MANAGER_ROLE) {
        merchantGracePeriods[merchantId] = gracePeriod;
    }
    
    function mintOrRenew(
        address user,
        uint256 merchantId,
        uint64 additionalPeriod
    ) external override onlyRole(MANAGER_ROLE) {
        SubscriptionStatus storage status = subscriptions[user][merchantId];
        
        uint64 currentTime = uint64(block.timestamp);
        uint64 newExpiry;
        
        if (status.expiresAt > currentTime) {
            // Renewal - extend from current expiry
            newExpiry = status.expiresAt + additionalPeriod;
        } else {
            // New or expired - start from now
            newExpiry = currentTime + additionalPeriod;
            status.startedAt = currentTime;
        }
        
        status.expiresAt = newExpiry;
        status.renewalCount++;
        status.lastPaymentAmount = 0; // Set by payment processor
        status.autoRenew = false; // Can be set separately
        
        if (balanceOf(user, merchantId) == 0) {
            _mint(user, merchantId, 1, "");
            emit SubscriptionMinted(user, merchantId, newExpiry, status.renewalCount);
        } else {
            emit SubscriptionRenewed(user, merchantId, newExpiry, status.renewalCount);
        }
    }
    
    function burnExpired(
        address user,
        uint256 merchantId
    ) external override {
        require(_canBurnExpired(user, merchantId), "Cannot burn");
        
        _burn(user, merchantId, 1);
        
        delete subscriptions[user][merchantId];
        
        emit SubscriptionBurned(user, merchantId);
    }
    
    function processBatchExpiry(
        address[] calldata users,
        uint256[] calldata merchantIds
    ) external override onlyRole(REACTIVE_ROLE) {
        require(users.length == merchantIds.length, "Length mismatch");
        
        for (uint256 i = 0; i < users.length; i++) {
            if (_canBurnExpired(users[i], merchantIds[i])) {
                _burn(users[i], merchantIds[i], 1);
                delete subscriptions[users[i]][merchantIds[i]];
                emit SubscriptionExpired(users[i], merchantIds[i]);
            }
        }
    }
    
    function onPaymentProcessed(
        address user,
        uint256 merchantId,
        uint64 expiresAt
    ) external override onlyRole(REACTIVE_ROLE) {
        SubscriptionStatus storage status = subscriptions[user][merchantId];
        
        if (status.expiresAt < expiresAt) {
            status.expiresAt = expiresAt;
            
            if (balanceOf(user, merchantId) == 0) {
                status.startedAt = uint64(block.timestamp);
                status.renewalCount = 0;
                _mint(user, merchantId, 1, "");
                emit SubscriptionMinted(user, merchantId, expiresAt, status.renewalCount);
            } else {
                status.renewalCount++;
                emit SubscriptionRenewed(user, merchantId, expiresAt, status.renewalCount);
            }
        }
    }
    
    function isSubscriptionActive(
        address user,
        uint256 merchantId
    ) external view override returns (bool) {
        return subscriptions[user][merchantId].expiresAt > block.timestamp;
    }
    
    function getSubscriptionStatus(
        address user,
        uint256 merchantId
    ) external view override returns (SubscriptionStatus memory) {
        return subscriptions[user][merchantId];
    }
    
    function getRemainingTime(
        address user,
        uint256 merchantId
    ) external view override returns (uint256) {
        uint64 expiresAt = subscriptions[user][merchantId].expiresAt;
        if (expiresAt <= block.timestamp) {
            return 0;
        }
        return expiresAt - block.timestamp;
    }
    
    function isInGracePeriod(
        address user,
        uint256 merchantId
    ) external view override returns (bool) {
        SubscriptionStatus memory status = subscriptions[user][merchantId];
        if (status.expiresAt >= block.timestamp) {
            return false; // Still active
        }
        
        uint64 gracePeriod = merchantGracePeriods[merchantId];
        uint64 graceEnd = status.expiresAt + gracePeriod;
        
        return block.timestamp <= graceEnd;
    }
    
    function pay() external payable override returns (uint256) {
        // Implementation of pay function for debt settlement
        // Inherited from AbstractCallback's vendor payment mechanism
        return msg.value;
    }
    
    function _canBurnExpired(address user, uint256 merchantId) private view returns (bool) {
        if (balanceOf(user, merchantId) == 0) {
            return false;
        }
        
        SubscriptionStatus memory status = subscriptions[user][merchantId];
        if (status.expiresAt >= block.timestamp) {
            return false; // Still active
        }
        
        uint64 gracePeriod = merchantGracePeriods[merchantId];
        uint64 graceEnd = status.expiresAt + gracePeriod;
        
        return block.timestamp > graceEnd;
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}