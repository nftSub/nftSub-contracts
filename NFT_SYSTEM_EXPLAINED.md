# NFT Subscription System Explained

## How the ERC-1155 Token System Works

### Core Concept: Token ID = Merchant ID

The subscription system uses **ERC-1155** (multi-token standard) where:
- **Token ID = Merchant ID**
- Each merchant has their own unique token ID
- Users can hold NFTs from multiple merchants simultaneously

### Visual Example

```
User Alice (0xAlice...)
├── Token ID 1 (Merchant 1: Netflix-like service)     → Balance: 1 NFT
├── Token ID 2 (Merchant 2: Spotify-like service)     → Balance: 1 NFT  
└── Token ID 5 (Merchant 5: Gaming subscription)      → Balance: 1 NFT

User Bob (0xBob...)
├── Token ID 1 (Merchant 1: Netflix-like service)     → Balance: 1 NFT
└── Token ID 3 (Merchant 3: Cloud storage)            → Balance: 1 NFT
```

## Key Implementation Details

### 1. NFT Minting Process

When a user subscribes to a merchant:

```solidity
// Line 66 in SubscriptionNFT.sol
_mint(user, merchantId, 1, "");
```

This means:
- `user`: The subscriber's wallet address
- `merchantId`: The token ID (represents which merchant)
- `1`: Amount of NFTs (always 1 for subscriptions)
- Each user can only have 0 or 1 NFT per merchant

### 2. How User-Merchant Relationships Work

The contract maintains a mapping:
```solidity
mapping(address => mapping(uint256 => SubscriptionStatus)) private subscriptions;
//      ↑ user         ↑ merchantId
```

This creates a 2D relationship table:
```
subscriptions[userAddress][merchantId] = {
    expiresAt: timestamp,
    startedAt: timestamp,
    renewalCount: number,
    lastPaymentAmount: amount,
    paymentToken: address,
    autoRenew: boolean
}
```

### 3. Checking Subscription Status

To check if a user has an active subscription:

```solidity
// Check NFT balance
balanceOf(userAddress, merchantId) > 0  // Has the NFT

// Check if still valid
subscriptions[userAddress][merchantId].expiresAt > block.timestamp  // Not expired
```

## Real-World Examples

### Example 1: Multiple Subscriptions
```
Alice subscribes to:
- Merchant 1 (Streaming): Holds NFT with token ID 1
- Merchant 2 (Music): Holds NFT with token ID 2
- Merchant 5 (Games): Holds NFT with token ID 5

Alice's NFT collection:
- balanceOf(Alice, 1) = 1  ✓ Active streaming subscription
- balanceOf(Alice, 2) = 1  ✓ Active music subscription
- balanceOf(Alice, 3) = 0  ✗ No subscription to merchant 3
- balanceOf(Alice, 4) = 0  ✗ No subscription to merchant 4
- balanceOf(Alice, 5) = 1  ✓ Active gaming subscription
```

### Example 2: Subscription Lifecycle
```
1. Alice subscribes to Merchant 1
   → Mints NFT: _mint(Alice, 1, 1)
   → Alice now owns 1 NFT of token ID 1

2. Alice's subscription expires (after 30 days)
   → NFT still exists but status.expiresAt < now
   → Access denied but grace period active

3. Alice renews before grace period ends
   → Same NFT updated: status.expiresAt extended
   → No new minting, just metadata update

4. Alice doesn't renew, grace period ends
   → NFT burned: _burn(Alice, 1, 1)
   → Alice now owns 0 NFTs of token ID 1
```

## Why ERC-1155 Instead of ERC-721?

### ERC-1155 Advantages:
1. **Gas Efficiency**: Batch operations for multiple subscriptions
2. **Simple ID System**: Token ID = Merchant ID (no need for complex token ID generation)
3. **Easy Queries**: `balanceOf(user, merchantId)` tells you instantly if subscribed
4. **Bulk Transfers**: Users can transfer multiple subscriptions in one transaction

### If This Were ERC-721:
```
// Would need unique token IDs for each subscription
Token #1: Alice's subscription to Merchant 1
Token #2: Bob's subscription to Merchant 1  
Token #3: Alice's subscription to Merchant 2
// Complex tracking and higher gas costs
```

## Metadata URI Explanation

The URI pattern: `https://api.subscription-nft.io/metadata/11155111/{id}`

When queried for a specific NFT:
- `{id}` is replaced with the merchant ID
- For merchant 1: `https://api.subscription-nft.io/metadata/11155111/1`
- For merchant 2: `https://api.subscription-nft.io/metadata/11155111/2`

This returns JSON metadata like:
```json
{
  "name": "Premium Subscription - Merchant Name",
  "description": "Active subscription to Merchant's premium service",
  "image": "https://...",
  "attributes": [
    {
      "trait_type": "Merchant",
      "value": "Merchant Name"
    },
    {
      "trait_type": "Tier",
      "value": "Premium"
    },
    {
      "trait_type": "Status",
      "value": "Active"
    }
  ]
}
```

## Access Control Flow

```mermaid
graph LR
    A[User visits merchant site] --> B{Check NFT Balance}
    B -->|balanceOf(user, merchantId) > 0| C{Check Expiry}
    B -->|Balance = 0| D[No Access]
    C -->|Not Expired| E[Grant Access]
    C -->|Expired but in Grace| F[Limited Access]
    C -->|Expired past Grace| G[Burn NFT & Deny]
```

## Summary

- **One Token ID per Merchant**: Each merchant gets a unique token ID
- **Users Hold Multiple NFTs**: Can subscribe to many merchants
- **Balance Represents Subscription**: Having 1 NFT = active subscription
- **Efficient Queries**: Easy to check who subscribes to what
- **Grace Period Handling**: NFT exists but access limited during grace
- **Clean Separation**: Each merchant's subscribers are isolated by token ID

This design makes it extremely gas-efficient and simple to manage subscriptions at scale!