# Deployment Guide

## Prerequisites

1. **Node.js**: v20.2.0 or higher
2. **MetaMask**: Wallet with testnet ETH
3. **PYUSD Testnet Tokens**: Get from Google Cloud or Paxos faucets
4. **API Keys**:
   - Arbiscan API key (for contract verification)
   - Optional: Infura or Alchemy RPC URL

## Step 1: Environment Setup

Create a `.env` file in the root directory:

```env
# Private key of deployer account
PRIVATE_KEY=your_private_key_here

# RPC URLs
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ETHEREUM_SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY

# Block Explorer API Keys
ARBISCAN_API_KEY=your_arbiscan_api_key
ETHERSCAN_API_KEY=your_etherscan_api_key

# PYUSD Token Address (Testnet)
# IMPORTANT: Update with actual PYUSD testnet address
PYUSD_ADDRESS=0x... 
```

## Step 2: Install Dependencies

```bash
npm install
```

## Step 3: Get PYUSD Testnet Tokens

### Option A: Google Cloud Faucet
1. Visit the Google Cloud Faucet for PYUSD
2. Connect your wallet
3. Request testnet PYUSD

### Option B: Paxos Faucet
1. Visit Paxos faucet
2. Enter your wallet address
3. Receive testnet tokens

### Option C: Manual Transfer (if available)
If you have access to testnet PYUSD, transfer from another wallet.

## Step 4: Compile Contracts

```bash
npm run compile
```

## Step 5: Run Tests (Optional)

```bash
npm test
```

## Step 6: Deploy to Arbitrum Sepolia

```bash
npm run deploy:arbitrum
```

Or manually:

```bash
npx hardhat run scripts/deploy.js --network arbitrumSepolia
```

## Step 7: Verify Contract on Arbiscan

The deployment script automatically verifies the contract. If manual verification is needed:

```bash
npx hardhat verify --network arbitrumSepolia <CONTRACT_ADDRESS> <PYUSD_ADDRESS>
```

## Step 8: Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env.local`:
```env
NEXT_PUBLIC_CONTRACT_ADDRESS=0x... # From deployment output
NEXT_PUBLIC_PYUSD_ADDRESS=0x... # PYUSD testnet address
```

4. Run development server:
```bash
npm run dev
```

5. Open browser to http://localhost:3000

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Dependencies installed
- [ ] PYUSD testnet tokens obtained
- [ ] Contracts compiled successfully
- [ ] Tests passing (optional)
- [ ] Contract deployed to testnet
- [ ] Contract verified on block explorer
- [ ] Frontend configured with contract address
- [ ] Frontend running and accessible

## Testing the Deployment

1. **Connect Wallet**: Click "Connect Wallet" in the frontend
2. **Get PYUSD**: Ensure you have testnet PYUSD in your wallet
3. **Subscribe**: Click "Subscribe" on a plan
4. **Approve Transaction**: Approve PYUSD spending in MetaMask
5. **Confirm Subscription**: Confirm the subscription transaction
6. **Verify**: Check subscription status on the blockchain

## PYUSD Testnet Addresses

### Arbitrum Sepolia (Recommended)
- **PYUSD**: Update with actual testnet address
- **Block Explorer**: https://sepolia.arbiscan.io/

### Ethereum Sepolia
- **PYUSD**: Update with actual testnet address
- **Block Explorer**: https://sepolia.etherscan.io/

## Troubleshooting

### Issue: "Insufficient funds"
**Solution**: Ensure you have enough testnet ETH for gas fees and PYUSD for subscription payments.

### Issue: "Transaction reverted"
**Solution**: 
- Check if you have approved the PYUSD spending
- Verify the PYUSD address is correct
- Ensure the plan exists and is active

### Issue: Contract verification failed
**Solution**:
- Wait a few minutes after deployment
- Verify manually using hardhat verify command
- Ensure API key is correct

## Network Configuration

### Arbitrum Sepolia
- **Chain ID**: 421614
- **RPC URL**: https://sepolia-rollup.arbitrum.io/rpc
- **Explorer**: https://sepolia.arbiscan.io/

### Ethereum Sepolia
- **Chain ID**: 11155111
- **RPC URL**: https://sepolia.infura.io/v3/KEY
- **Explorer**: https://sepolia.etherscan.io/

## Security Notes

1. **Never commit private keys**: The `.env` file is in `.gitignore`
2. **Use testnet only**: This deployment is for testing purposes
3. **Verify contract**: Always verify contracts on block explorers
4. **Test thoroughly**: Test all functions before mainnet deployment

## Next Steps

1. Create additional subscription plans as needed
2. Set up automated payment processing
3. Configure puller authorization for auto-renewals
4. Implement additional features as required

## Support

For issues or questions:
- Check the [README.md](README.md) for general information
- Review contract code in `contracts/`
- Check test files in `test/`

## Production Deployment

For production deployment to mainnet:
1. Update PYUSD address to mainnet address
2. Configure production network in `hardhat.config.js`
3. Use production API keys
4. Conduct thorough security audit
5. Test on testnet thoroughly before mainnet
