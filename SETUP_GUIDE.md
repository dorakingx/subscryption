# Setup Guide - PYUSD Testnet Configuration

## ✅ PYUSDテストトークンを取得済み

Ethereum SepoliaでPYUSDテストトークンを取得しました。
トランザクション: https://sepolia.etherscan.io/tx/0xbc5c4b5de28ff5197fcdd2b88602b76242469a46d3d33b98de67f8924cbb1320

## 次のステップ

### 1. PYUSDコントラクトアドレスの確認

トランザクション詳細からPYUSDコントラクトアドレスを確認してください：

1. https://sepolia.etherscan.io/tx/0xbc5c4b5de28ff5197fcdd2b88602b76242469a46d3d33b98de67f8924cbb1320 にアクセス
2. "Token" または "To" セクションでPYUSDコントラクトアドレスを確認
3. そのアドレスをコピー

### 2. .envファイルの設定

```bash
# .envファイルを編集
nano .env
```

以下のように設定してください：

```env
PRIVATE_KEY=0x... # あなたのプライベートキー
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ETHEREUM_SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
PYUSD_ADDRESS=0x... # ステップ1で取得したPYUSDアドレス
```

### 3. ネットワークの選択

Ethereum SepoliaでPYUSDを取得したので、Ethereum Sepoliaにデプロイすることを推奨します。

#### Option A: Ethereum Sepolia

```bash
npm run deploy:sepolia
```

#### Option B: Arbitrum Sepolia（別途Arbitrum用PYUSDが必要）

```bash
npm run deploy:arbitrum
```

## 必要な情報

- [ ] PYUSDコントラクトアドレス（上記ステップ1から取得）
- [ ] プライベートキー（デプロイ用ウォレット）
- [ ] Sepolia ETH（ガス代用）

## Sepolia ETHの取得

ガス代用のSepolia ETHが必要です：

1. **Chainlink Faucet**: https://faucets.chain.link/
2. **Alchemy Faucet**: https://www.alchemy.com/faucets/ethereum-sepolia
3. **Infura Faucet**: https://www.infura.io/faucet/sepolia

## デプロイの準備

すべての準備ができたら：

```bash
# コンパイル
npm run compile

# テスト（オプション）
npm test

# デプロイ
npm run deploy:sepolia
```

## トラブルシューティング

### ガス不足のエラー
- Sepolia ETHの追加取得

### プライベートキーの設定
- `.env`ファイルに正しく設定されているか確認
- 先頭に`0x`が含まれているか確認

### PYUSDアドレスのエラー
- トランザクション詳細から正確なコントラクトアドレスを取得
- テストネットのアドレスを使用しているか確認（メインネットではない）

## サポート

問題が発生した場合は、以下を確認してください：
- [QUICK_START.md](QUICK_START.md)
- [DEPLOYMENT.md](DEPLOYMENT.md)
