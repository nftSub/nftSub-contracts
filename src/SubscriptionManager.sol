// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ISubscriptionManager.sol";
import "./interfaces/ISubscriptionNFT.sol";
import "./libraries/SubscriptionConstants.sol";

contract SubscriptionManager is ISubscriptionManager, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SubscriptionConstants for *;
    
    uint16 public override platformFeeBps = SubscriptionConstants.DEFAULT_PLATFORM_FEE_BPS;
    address public subscriptionNFT;
    
    uint256 private nextMerchantId = 1;
    
    mapping(uint256 => MerchantPlan) private merchants;
    mapping(uint256 => mapping(address => uint256)) private merchantPrices;
    mapping(uint256 => mapping(address => MerchantBalance)) private merchantBalances;
    mapping(address => mapping(address => uint256)) private platformFees;
    
    modifier onlyActiveMerchant(uint256 merchantId) {
        require(merchants[merchantId].isActive, "Merchant not active");
        _;
    }
    
    modifier onlyMerchantOwner(uint256 merchantId) {
        require(msg.sender == _getMerchantOwner(merchantId), "Not merchant owner");
        _;
    }
    
    constructor() Ownable(msg.sender) {}
    
    function setSubscriptionNFT(address _nft) external onlyOwner {
        require(subscriptionNFT == address(0), "Already set");
        subscriptionNFT = _nft;
    }
    
    function setPlatformFee(uint16 _feeBps) external onlyOwner {
        require(_feeBps <= SubscriptionConstants.MAX_FEE_BPS, "Fee too high");
        platformFeeBps = _feeBps;
    }
    
    function registerMerchant(
        address payoutAddress,
        uint64 subscriptionPeriod,
        uint64 gracePeriod
    ) external override returns (uint256 merchantId) {
        require(payoutAddress != address(0), "Invalid payout address");
        require(subscriptionPeriod > 0, "Invalid period");
        
        merchantId = nextMerchantId++;
        
        merchants[merchantId] = MerchantPlan({
            payoutAddress: payoutAddress,
            subscriptionPeriod: subscriptionPeriod,
            gracePeriod: gracePeriod,
            isActive: true,
            totalSubscribers: 0
        });
        
        emit MerchantRegistered(merchantId, msg.sender, payoutAddress);
    }
    
    function updateMerchantPlan(
        uint256 merchantId,
        address payoutAddress,
        uint64 subscriptionPeriod,
        bool isActive
    ) external override onlyMerchantOwner(merchantId) {
        require(payoutAddress != address(0), "Invalid payout address");
        require(subscriptionPeriod > 0, "Invalid period");
        
        MerchantPlan storage plan = merchants[merchantId];
        plan.payoutAddress = payoutAddress;
        plan.subscriptionPeriod = subscriptionPeriod;
        plan.isActive = isActive;
    }
    
    function setMerchantPrice(
        uint256 merchantId,
        address paymentToken,
        uint256 price
    ) external override onlyMerchantOwner(merchantId) {
        require(price > 0, "Invalid price");
        merchantPrices[merchantId][paymentToken] = price;
    }
    
    function subscribe(
        uint256 merchantId,
        address paymentToken
    ) external payable override onlyActiveMerchant(merchantId) nonReentrant {
        uint256 price = merchantPrices[merchantId][paymentToken];
        require(price > 0, "Token not accepted");
        
        uint256 platformFee = (price * platformFeeBps) / 10000;
        uint256 merchantAmount = price - platformFee;
        
        if (paymentToken == address(0)) {
            require(msg.value == price, "Incorrect ETH amount");
        } else {
            require(msg.value == 0, "ETH not expected");
            IERC20(paymentToken).safeTransferFrom(msg.sender, address(this), price);
        }
        
        MerchantBalance storage balance = merchantBalances[merchantId][paymentToken];
        balance.totalReceived += price;
        balance.pendingAmount += merchantAmount;
        
        platformFees[owner()][paymentToken] += platformFee;
        
        MerchantPlan storage plan = merchants[merchantId];
        plan.totalSubscribers++;
        
        emit PaymentReceived(
            msg.sender,
            merchantId,
            paymentToken,
            price,
            platformFee,
            plan.subscriptionPeriod
        );
        
        if (subscriptionNFT != address(0)) {
            ISubscriptionNFT(subscriptionNFT).mintOrRenew(
                msg.sender,
                merchantId,
                plan.subscriptionPeriod
            );
        }
    }
    
    function withdrawMerchantBalance(
        uint256 merchantId,
        address token
    ) external override onlyMerchantOwner(merchantId) nonReentrant {
        MerchantBalance storage balance = merchantBalances[merchantId][token];
        uint256 amount = balance.pendingAmount;
        require(amount > 0, "No balance");
        
        balance.pendingAmount = 0;
        balance.totalWithdrawn += amount;
        balance.lastWithdrawal = uint64(block.timestamp);
        
        address payoutAddress = merchants[merchantId].payoutAddress;
        
        if (token == address(0)) {
            (bool success, ) = payable(payoutAddress).call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(payoutAddress, amount);
        }
        
        emit MerchantWithdrawal(merchantId, token, amount, payoutAddress);
    }
    
    function withdrawPlatformFees(
        address token,
        address to
    ) external override onlyOwner nonReentrant {
        uint256 amount = platformFees[owner()][token];
        require(amount > 0, "No fees");
        
        platformFees[owner()][token] = 0;
        
        if (token == address(0)) {
            (bool success, ) = payable(to).call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
        
        emit PlatformFeeWithdrawal(token, amount, to);
    }
    
    function getMerchantPlan(uint256 merchantId) 
        external view override returns (MerchantPlan memory) {
        return merchants[merchantId];
    }
    
    function getMerchantBalance(uint256 merchantId, address token)
        external view override returns (uint256) {
        return merchantBalances[merchantId][token].pendingAmount;
    }
    
    function getMerchantPrice(uint256 merchantId, address token)
        external view override returns (uint256) {
        return merchantPrices[merchantId][token];
    }
    
    function isMerchantTokenAccepted(uint256 merchantId, address token)
        external view override returns (bool) {
        return merchantPrices[merchantId][token] > 0;
    }
    
    function _getMerchantOwner(uint256 merchantId) private view returns (address) {
        // In production, track merchant owners separately
        // For now, using a simplified approach
        return merchants[merchantId].payoutAddress;
    }
}