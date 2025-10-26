# PYUSD Subscription Service

A decentralized subscription service powered by PayPal USD (PYUSD) smart contracts on Arbitrum Sepolia testnet.

## Overview

This project implements a programmable subscription system using PYUSD (PayPal USD) as the payment token. It leverages the programmable features of PYUSD to enable automated recurring payments, low transaction costs, and 24/7 availability.

## Features

- **Multiple Subscription Plans**: Flexible pricing with customizable billing periods
- **PYUSD Payments**: All payments processed in PYUSD tokens
- **Automated Renewals**: Programmable payment logic for automatic billing
- **ERC20 Permit Support**: Gasless approvals using EIP-2612
- **Access Control**: Secure subscription management with role-based permissions
- **Pause/Unpause**: Emergency controls for contract security

## Project Structure

```
subscryption/
├── contracts/
│   ├── PYUSDSubscription.sol    # Main subscription contract
│   └── IPYUSD.sol               # PYUSD token interface
├── test/
│   └── PYUSDSubscription.test.js
├── frontend/
│   └── app/
│       ├── layout.js
│       └── page.js
├── hardhat.config.js
└── README.md
```

## Smart Contract Features

### Core Functionality

1. **Plan Management**: Create and manage subscription plans with customizable prices and billing periods
2. **Subscribe**: Users can subscribe to plans using standard approve/transfer or permit
3. **Auto-Renewal**: Authorized pullers can process recurring payments automatically
4. **Cancellation**: Users can cancel subscriptions at any time
5. **Access Control**: Check subscription status for any user

### Key Functions

- `createPlan()`: Create new subscription plans
- `subscribe()`: Standard subscription with approve/transfer
- `subscribeWithPermit()`: Gasless subscription using permit
- `processPayment()`: Process recurring payments (authorized pullers only)
- `cancelSubscription()`: Cancel active subscription
- `isSubscribed()`: Check if address has active subscription

## Deployment

### Prerequisites

- Node.js (v20.2.0 or higher)
- MetaMask or compatible wallet
- Testnet PYUSD tokens

### PYUSD Testnet Addresses

**Arbitrum Sepolia:**
```
PYUSD: 0x... (update with actual testnet address)
```

**Ethereum Sepolia:**
```
PYUSD: 0x... (update with actual testnet address)
```

Get testnet PYUSD from:
- Google Cloud Faucet
- Paxos Faucet

### Environment Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file:
```env
PRIVATE_KEY=your_private_key_here
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ARBISCAN_API_KEY=your_arbiscan_api_key
PYUSD_ADDRESS=0x... # Testnet PYUSD address
```

3. Compile contracts:
```bash
npx hardhat compile
```

4. Deploy to Arbitrum Sepolia:
```bash
npx hardhat run scripts/deploy.js --network arbitrumSepolia
```

## Testing

Run tests:
```bash
npx hardhat test
```

## Frontend Integration

The frontend is built with Next.js and ethers.js v6.

### Running the Frontend

```bash
cd frontend
npm install
npm run dev
```

### Environment Variables

Create `frontend/.env.local`:
```env
NEXT_PUBLIC_CONTRACT_ADDRESS=0x...
NEXT_PUBLIC_PYUSD_ADDRESS=0x...
```

## Usage Example

### Subscribe to a Plan

```javascript
// Connect wallet
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// Approve PYUSD
const pyusdContract = new ethers.Contract(pyusdAddress, pyusdAbi, signer);
await pyusdContract.approve(contractAddress, planPrice);

// Subscribe
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
await contract.subscribe(planId);
```

### Using Permit (Gasless Approval)

```javascript
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

await contract.subscribeWithPermit(planId, v, r, s, deadline);
```

## Security Considerations

- Contract uses OpenZeppelin's ReentrancyGuard and Pausable
- Ownable pattern for admin functions
- Access control for payment processing
- SafeMath for arithmetic operations
- Comprehensive event logging

## License

MIT

## Contributing

Contributions are welcome! Please ensure your code follows the existing style and includes appropriate tests.

## Resources

- [PYUSD Documentation](https://www.paypal.com/pyusd)
- [Hardhat Documentation](https://hardhat.org/)
- [OpenZeppelin Contracts](https://docs.openzepelin.com/contracts/)
- [Ethers.js Documentation](https://docs.ethers.io/)
