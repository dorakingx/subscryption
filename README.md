# PYUSD Subscription Service

A decentralized subscription service powered by PayPal USD (PYUSD) smart contracts. This project implements a programmable subscription system using PYUSD as the payment token, enabling automated recurring payments, low transaction costs, and 24/7 availability.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Smart Contract Features](#smart-contract-features)
- [Installation](#installation)
- [Deployment](#deployment)
- [Testing](#testing)
- [Frontend](#frontend)
- [Usage Examples](#usage-examples)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

The PYUSD Subscription Service is a decentralized application (dApp) that enables programmable, recurring payments using PayPal USD (PYUSD) on blockchain networks. The system consists of smart contracts and a web frontend that interact to provide a seamless subscription experience.

### Key Benefits

- **Programmability**: Leverages PYUSD's programmable features for automated recurring payments
- **Low Cost**: Minimal transaction fees, especially on L2 networks like Arbitrum
- **24/7 Availability**: No banking hours constraints
- **Global Access**: Accessible from anywhere in the world
- **Transparency**: All transactions recorded on the blockchain

## Features

- **Multiple Subscription Plans**: Flexible pricing with customizable billing periods
- **PYUSD Payments**: All payments processed in PYUSD tokens
- **Automated Renewals**: Programmable payment logic for automatic billing
- **ERC20 Permit Support**: Gasless approvals using EIP-2612
- **Access Control**: Secure subscription management with role-based permissions
- **Pause/Unpause**: Emergency controls for contract security
- **Expired Subscription Handling**: Automatic or manual status updates
- **Comprehensive Event Logging**: Full audit trail of all operations

## Architecture

### System Architecture

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
│  │  │  - updateExpiredSubscription()                 │  │ │
│  │  └────────────────────────────────────────────────┘  │ │
│  │  ┌────────────────────────────────────────────────┐  │ │
│  │  │  Access Control                                │  │ │
│  │  │  - setPullerAuthorization()                    │  │ │
│  │  │  - pause() / unpause()                         │  │ │
│  │  │  - emergencyWithdraw()                         │  │ │
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

### Component Details

#### Smart Contracts

**PYUSDSubscription.sol**
- Main subscription contract implementing all business logic
- Uses OpenZeppelin's Ownable, ReentrancyGuard, and Pausable
- Leverages Solidity 0.8.x built-in overflow protection
- Key structures: `SubscriptionPlan`, `UserSubscription`

**IPYUSD.sol**
- Interface for PYUSD token with ERC20 Permit support
- Enables gasless approvals via EIP-2612

#### Frontend

**Technology Stack**
- Next.js 16 (React framework)
- ethers.js v6 for Web3 interactions
- MetaMask for wallet connectivity
- HTML/CSS/JavaScript for UI

**Key Components**
- Wallet connection integration
- Subscription plan display
- Transaction handling and error management
- Payment approval and subscription flows

## Project Structure

```
subscryption/
├── contracts/
│   ├── PYUSDSubscription.sol    # Main subscription contract
│   └── IPYUSD.sol               # PYUSD token interface
├── test/
│   └── PYUSDSubscription.test.js
├── scripts/
│   └── deploy.js                # Deployment script
├── frontend/
│   ├── app/
│   │   ├── layout.js
│   │   └── page.js
│   ├── index.html               # Standalone HTML interface
│   ├── simple-server.js         # HTTP server
│   └── package.json
├── hardhat.config.js
├── package.json
├── README.md
└── .env.template
```

## Smart Contract Features

### Core Functionality

1. **Plan Management**
   - Create subscription plans with customizable prices and billing periods
   - Enable/disable plans as needed
   - Track current subscriber count
   - Set maximum subscriber limits

2. **Subscription Operations**
   - Standard subscription via approve/transferFrom
   - Gasless subscription via ERC20 Permit
   - Automatic renewal processing by authorized pullers
   - User-initiated cancellation
   - Subscription status checking

3. **Advanced Features**
   - Expired subscription status updates
   - Comprehensive event logging
   - Emergency pause/unpause functionality
   - Controlled emergency withdrawals

### Key Functions

- `createPlan()`: Create new subscription plans
- `updatePlanStatus()`: Enable/disable plans
- `subscribe()`: Standard subscription with approve/transfer
- `subscribeWithPermit()`: Gasless subscription using permit
- `processPayment()`: Process recurring payments (authorized pullers only)
- `cancelSubscription()`: Cancel active subscription
- `isSubscribed()`: Check if address has active subscription
- `updateExpiredSubscription()`: Update status of expired subscriptions
- `emergencyWithdraw()`: Emergency token withdrawal (owner only)

## Installation

### Prerequisites

- **Node.js**: v20.9.0 or higher (Note: v20.2.0 works but v20.9.0+ recommended for Next.js)
- **npm**: v9.6.6 or higher
- **MetaMask**: Browser extension wallet
- **Testnet PYUSD Tokens**: Required for deployment and testing

### Step 1: Clone Repository

```bash
git clone https://github.com/dorakingx/subscryption.git
cd subscryption
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Frontend Setup

```bash
cd frontend
npm install --legacy-peer-deps
cd ..
```

## Deployment

### Step 1: Environment Configuration

Create a `.env` file in the root directory:

```env
# Deployer account private key (REQUIRED)
PRIVATE_KEY=your_private_key_here

# RPC URLs (Optional - defaults are public RPCs)
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ETHEREUM_SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY

# Block Explorer API Keys (Optional - for contract verification)
ARBISCAN_API_KEY=your_arbiscan_api_key
ETHERSCAN_API_KEY=your_etherscan_api_key

# PYUSD Token Address (REQUIRED)
PYUSD_ADDRESS=0x... # Replace with actual PYUSD testnet address
```

**Important**: Never commit the `.env` file to version control.

### Step 2: Get PYUSD Testnet Tokens

#### Option A: From Block Explorer
1. Visit the transaction that received PYUSD testnet tokens
2. Identify the PYUSD contract address from the transaction details
3. Copy the contract address to your `.env` file

#### Option B: Official Faucets
- Google Cloud Faucet
- Paxos Faucet

#### Option C: Manual Transfer
If you have access to testnet PYUSD, transfer from another wallet.

### Step 3: Get Sepolia ETH

For gas fees, you'll need Sepolia ETH from:
- [Chainlink Faucet](https://faucets.chain.link/)
- [Alchemy Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)
- [Infura Faucet](https://www.infura.io/faucet/sepolia)

### Step 4: Compile Contracts

```bash
npm run compile
```

### Step 5: Deploy

#### Deploy to Arbitrum Sepolia

```bash
npm run deploy:arbitrum
```

#### Deploy to Ethereum Sepolia

```bash
npm run deploy:sepolia
```

### Step 6: Contract Verification

The deployment script automatically attempts to verify the contract on the block explorer. Manual verification:

```bash
npx hardhat verify --network arbitrumSepolia <CONTRACT_ADDRESS> <PYUSD_ADDRESS>
```

### Step 7: Update Frontend Configuration

After deployment, update `frontend/.env.local`:

```env
NEXT_PUBLIC_CONTRACT_ADDRESS=0x... # From deployment output
NEXT_PUBLIC_PYUSD_ADDRESS=0x... # PYUSD testnet address
```

## Testing

### Run Tests

```bash
npm test
```

### Test Coverage

Current tests include:
- Deployment verification
- Plan creation
- Plan management
- Access control

**Note**: Enhanced test coverage with mock ERC20 tokens and comprehensive edge case testing is recommended.

## Frontend

### Running the Frontend

#### Option A: Simple HTTP Server (Recommended for Quick Start)

```bash
cd frontend
node simple-server.js
```

Open http://localhost:3000 in your browser.

#### Option B: Next.js Development Server

```bash
cd frontend
npm run dev
```

**Note**: Requires Node.js v20.9.0 or higher for Next.js.

### Frontend Features

- Wallet connection via MetaMask
- Display subscription plans
- Subscription management interface
- Transaction status tracking
- Error handling and user feedback

## Usage Examples

### Subscribe to a Plan (Standard Method)

```javascript
// 1. Connect wallet
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// 2. Approve PYUSD
const pyusdContract = new ethers.Contract(pyusdAddress, pyusdAbi, signer);
await pyusdContract.approve(contractAddress, planPrice);

// 3. Subscribe
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
await contract.subscribe(planId);
```

### Subscribe with Permit (Gasless Method)

```javascript
// 1. Create EIP-2612 permit signature
const domain = {
  name: await pyusdContract.name(),
  version: await pyusdContract.version(),
  chainId: await provider.getNetwork().then(n => n.chainId),
  verifyingContract: pyusdAddress
};

const types = {
  Permit: [
    { name: "owner", type: "address" },
    { name: "spender", type: "address" },
    { name: "value", type: "uint256" },
    { name: "nonce", type: "uint256" },
    { name: "deadline", type: "uint256" }
  ]
};

const value = {
  owner: userAddress,
  spender: contractAddress,
  value: planPrice,
  nonce: await pyusdContract.nonces(userAddress),
  deadline: deadline
};

const signature = await signer.signTypedData(domain, types, value);
const { r, s, v } = ethers.Signature.from(signature);

// 2. Subscribe with permit
await contract.subscribeWithPermit(planId, v, r, s, deadline);
```

### Check Subscription Status

```javascript
const isActive = await contract.isSubscribed(userAddress);
console.log(`Subscription active: ${isActive}`);

const subscription = await contract.getUserSubscription(userAddress);
console.log(`Plan ID: ${subscription.planId}`);
console.log(`Next billing date: ${subscription.nextBillingDate}`);
```

### Cancel Subscription

```javascript
await contract.cancelSubscription();
```

## Security

### Smart Contract Security Features

1. **Reentrancy Protection**
   - Uses OpenZeppelin's ReentrancyGuard
   - Prevents reentrancy attacks on all state-changing functions

2. **Access Control**
   - Ownable pattern for owner-only functions
   - Authorized puller system for payment processing
   - Public read-only functions for transparency

3. **Emergency Controls**
   - Pause/unpause functionality
   - Emergency withdrawal with security recommendations
   - Time-lock mechanism for large withdrawals (recommended)

4. **Input Validation**
   - All inputs validated with descriptive error messages
   - Zero address checks
   - Balance and allowance checks
   - Deadline validation for permit operations

5. **Arithmetic Safety**
   - Solidity 0.8.x built-in overflow/underflow protection
   - Removed custom SafeMath library
   - Safe arithmetic operations throughout

### Security Recommendations

For production deployment, consider implementing:
- Multi-sig wallet for owner functions
- Time-lock mechanism for emergency withdrawals
- Maximum withdrawal limits per transaction
- Rate limiting on operations
- Comprehensive audit by security experts

## Troubleshooting

### Common Issues

#### "Insufficient funds"
- **Solution**: Ensure you have enough testnet ETH for gas fees and PYUSD for subscription payments

#### "Transaction reverted"
- **Solution**: 
  - Verify PYUSD address is correct
  - Check if you have approved PYUSD spending
  - Ensure the plan exists and is active

#### "Insufficient allowance"
- **Solution**: Approve PYUSD spending before subscribing or ensure sufficient allowance for recurring payments

#### "Permit deadline has expired"
- **Solution**: Use a future deadline (e.g., now + 1 hour) when creating permit signatures

#### "Node.js version incompatible"
- **Solution**: Upgrade to Node.js v20.9.0 or higher

#### Contract verification failed
- **Solution**:
  - Wait a few minutes after deployment
  - Verify manually using hardhat verify command
  - Ensure API key is correct

### Network Configuration

#### Arbitrum Sepolia (Recommended)
- Chain ID: 421614
- RPC URL: https://sepolia-rollup.arbitrum.io/rpc
- Block Explorer: https://sepolia.arbiscan.io/
- Block Time: ~0.25 seconds

#### Ethereum Sepolia
- Chain ID: 11155111
- RPC URL: https://sepolia.infura.io/v3/KEY
- Block Explorer: https://sepolia.etherscan.io/
- Block Time: ~12 seconds

## Future Enhancements

- Enhanced test coverage with mock ERC20 contracts
- Payment streaming functionality
- Multi-token support (additional stablecoins)
- Partial refund system for unused periods
- Analytics dashboard for revenue tracking
- NFT integration for subscription tokens
- Governance mechanism for plan management

## Contributing

Contributions are welcome! Please ensure your code follows the existing style and includes appropriate tests.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

MIT

## Resources

- [PYUSD Documentation](https://www.paypal.com/pyusd)
- [Hardhat Documentation](https://hardhat.org/)
- [OpenZeppelin Contracts](https://docs.openzepelin.com/contracts/)
- [Ethers.js Documentation](https://docs.ethers.io/)
- [EIP-2612 Permit Standard](https://eips.ethereum.org/EIPS/eip-2612)

## Support

For issues, questions, or contributions:
- GitHub Issues: https://github.com/dorakingx/subscryption/issues
- Check existing documentation in the repository
- Review contract code in `contracts/`
- Check test files in `test/`

## Acknowledgments

This project leverages:
- OpenZeppelin for secure smart contract libraries
- Hardhat for development environment
- ethers.js for Web3 interactions
- PayPal for PYUSD stablecoin
