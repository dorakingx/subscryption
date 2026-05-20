const fs = require('fs');
const path = require('path');

const config = {
  contractAddress:
    process.env.NEXT_PUBLIC_CONTRACT_ADDRESS ||
    '0x3D8bE24704F15B7F290B986efced351f31e5B313',
  pyusdAddress:
    process.env.NEXT_PUBLIC_PYUSD_ADDRESS ||
    '0xCaC524BcA292aaade2DF8A05cC58F0a65B1B3bB9',
  chainId: Number(process.env.NEXT_PUBLIC_CHAIN_ID || '11155111'),
  explorerBaseUrl:
    process.env.NEXT_PUBLIC_EXPLORER_BASE_URL ||
    'https://sepolia.etherscan.io',
};

const outPath = path.join(__dirname, '..', 'public', 'runtime-config.js');
const content = `window.__RUNTIME_CONFIG = ${JSON.stringify(config, null, 2)};\n`;

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, content);
console.log('Generated', outPath);
