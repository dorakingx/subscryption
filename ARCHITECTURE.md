# PYUSD Subscription Service - Architecture

## Overview

The PYUSD Subscription Service is a decentralized application (dApp) that enables programmable, recurring payments using PayPal USD (PYUSD) on blockchain networks. The system consists of smart contracts and a web frontend that interact to provide a seamless subscription experience.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (Next.js)                       │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   React     │  │   Ethers.js  │  │   MetaMask       │   │
│  │  Components │◄─┤   Provider   │◄─┤   Integration    │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Web3 Calls
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  Smart Contract Layer                        │
│  ┌───────────────────────────────────────────────────────┐ │
│  │         PYUSDSubscription.sol                         │ │
│  │  ┌────────────────────────────────────────────────┐  │ │
│  │  │  Plan Management                                │  │ │
│  │  │  - createPlan()                                 │  │ │
│  │  │  - updatePlanStatus()                           │  │ │
│  │  │  - getPlan()                                    │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │  ┌────────────────────────────────────────────────┐  │ │
│  │  │  Subscription Management                       │  │ │
│  │  │  - subscribe()                                 │  │ │
│  │  │  - subscribeWithPermit()                       │  │ │
│  │  │  - processPayment()                            │  │ │
│  │  │  - cancelSubscription()                        │  │ │
│  │  │  - isSubscribed()                              │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │  ┌────────────────────────────────────────────────┐  │ │
│  │  │  Access Control                                │  │ │
│  │  │  - setPullerAuthorization()                    │  │ │
│  │  │  - pause() / unpause()                         │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────┘ │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Token Transfer
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  PYUSD Token (ERC-20)                        │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  Standard   │  │    Permit    │  │   Approve/Spend  │   │
│  │   Transfer  │  │   (EIP-2612) │  │   Allowance      │   │
│  └─────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Smart Contracts

#### PYUSDSubscription.sol
Main contract implementing the subscription logic.

**Key Structures:**
- `SubscriptionPlan`: Defines plan details (name, price, billing period, etc.)
- `UserSubscription`: Tracks user subscription state

**Security Features:**
- OpenZeppelin's Ownable for access control
- ReentrancyGuard to prevent reentrancy attacks
- Pausable for emergency stops

#### IPYUSD.sol
Interface for PYUSD token with Permit support.

**Functions:**
- Standard ERC-20 functions
- Permit (EIP-2612) for gasless approvals

### 2. Frontend

#### Technology Stack
- **Next.js 16**: React framework
- **ethers.js v6**: Ethereum interaction
- **Tailwind CSS**: Styling (configured in Next.js)

#### Key Components
- **Wallet Connection**: MetaMask integration
- **Subscription UI**: Plan selection and payment
- **Transaction Handling**: Approve and subscribe flows

### 3. Data Flow

#### Subscription Flow (Standard)
1. User connects wallet via MetaMask
2. Frontend displays available subscription plans
3. User clicks "Subscribe" on a plan
4. Frontend calls `approve()` on PYUSD token
5. User signs approve transaction in MetaMask
6. Frontend calls `subscribe()` on contract
7. User signs subscribe transaction
8. Contract transfers PYUSD from user to contract
9. Contract updates subscription state
10. Frontend displays success message

#### Subscription Flow (Permit)
1-3. Same as standard flow
4. Frontend creates EIP-2612 permit signature
5. User signs typed data in MetaMask
6. Frontend calls `subscribeWithPermit()` with signature
7. Contract verifies permit and transfers tokens
8-10. Same as standard flow

#### Auto-Renewal Flow
1. Billing cycle ends (nextBillingDate reached)
2. Authorized puller calls `processPayment()`
3. Contract checks allowance
4. Contract transfers PYUSD to contract
5. Contract updates nextBillingDate
6. Event emitted for tracking

## Security Architecture

### Contract Security

1. **Access Control**
   - Owner-only functions for admin operations
   - Authorized pullers for payment processing
   - Public read functions for status checks

2. **Reentrancy Protection**
   - ReentrancyGuard on all state-changing functions
   - Checks-Effects-Interactions pattern

3. **Input Validation**
   - Price > 0
   - Billing period > 0
   - Plan exists before subscription
   - Sufficient allowance before transfer

4. **Emergency Controls**
   - Pause functionality for critical issues
   - Emergency withdrawal for contract owner

### Frontend Security

1. **Environment Variables**
   - Contract addresses in `.env.local`
   - Never commit sensitive data

2. **Transaction Validation**
   - Check allowance before subscribing
   - Handle transaction failures gracefully
   - Display clear error messages

3. **Wallet Integration**
   - Standard wallet connection flow
   - Transaction signing through MetaMask

## Programmable Payment Logic

### ERC20 Permit
Allows users to sign approvals off-chain, enabling:
- Single transaction subscriptions
- Batch operations
- Better UX

### Automated Renewals
Service provider can:
1. Get list of active subscriptions
2. Check next billing dates
3. Call `processPayment()` for each subscriber
4. Handle failures appropriately

### Implementation Strategy

```javascript
// Backend service for auto-renewals
async function processRenewals() {
  const subscribers = await getActiveSubscribers();
  
  for (const subscriber of subscribers) {
    const subscription = await contract.getUserSubscription(subscriber);
    
    // Check if billing date reached
    if (block.timestamp >= subscription.nextBillingDate) {
      try {
        await contract.processPayment(subscriber);
        // Send notification
      } catch (error) {
        // Handle failure (insufficient allowance, etc.)
        // Send notification to subscriber
      }
    }
  }
}
```

## Scalability Considerations

### On-Chain
- Gas optimization with efficient data structures
- Storage optimization (packed structs)
- Event-based tracking for off-chain indexing

### Off-Chain
- Indexer for fast queries
- Backend service for automation
- Caching for frequently accessed data

## Network Configuration

### Arbitrum Sepolia (Recommended)
- Lower gas fees
- Faster transactions
- PYUSD testnet support
- Block time: ~0.25 seconds

### Ethereum Sepolia
- Mainnet-like environment
- Higher gas fees
- PYUSD testnet support
- Block time: ~12 seconds

## Future Enhancements

1. **Payment Streaming**
   - Continuous payment over time
   - Pro-rata refunds on cancellation

2. **Multi-Token Support**
   - Support for additional stablecoins
   - Currency conversion

3. **Refund System**
   - Partial refunds for unused periods
   - Refund policies per plan

4. **Analytics Dashboard**
   - Subscription metrics
   - Revenue tracking
   - User analytics

## Testing Strategy

### Unit Tests
- Contract function testing
- Edge cases
- Access control

### Integration Tests
- End-to-end flows
- Frontend-backend integration
- Multi-user scenarios

### Security Tests
- Reentrancy tests
- Access control tests
- Overflow tests

## Deployment Strategy

1. **Testnet Deployment**
   - Deploy to testnet first
   - Thorough testing
   - Bug fixes

2. **Verification**
   - Verify contracts on block explorer
   - Publish source code

3. **Mainnet Deployment**
   - Final security audit
   - Deploy to mainnet
   - Monitor transactions

## Monitoring and Maintenance

### Key Metrics
- Contract balance
- Active subscriptions
- Revenue generated
- Failed transactions

### Alerts
- Low contract balance
- Failed renewals
- High error rate
- Unusual activity

## License

MIT License - Open source for community use and improvement.
