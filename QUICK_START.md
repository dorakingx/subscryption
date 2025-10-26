# Quick Start Guide - PYUSD Subscription Service

## 重要な注意事項

⚠️ **実装済みですが、実際のデプロイには以下が必要です：**

1. **PYUSDテストネットアドレスの取得**: 現時点で正確なPYUSDテストネットアドレスが不明です
2. **Node.jsのアップグレード**: 現在のv20.2.0ではHardhatの一部機能が動作しない可能性があります
3. **テストネットPYUSDトークンの取得**: Google Cloud/Paxosファウセットから取得が必要です

## セットアップ手順

### 1. 環境ファイルの作成

`.env`ファイルを作成して以下を設定してください：

```bash
# .envファイルを作成
cat > .env << 'EOF'
PRIVATE_KEY=your_private_key_here
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ETHEREUM_SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
ARBISCAN_API_KEY=your_arbiscan_api_key
ETHERSCAN_API_KEY=your_etherscan_api_key
PYUSD_ADDRESS=0x... # PYUSDテストネットアドレス（取得が必要）
EOF
```

### 2. PYUSDテストネットアドレスの取得方法

#### Option A: Paxosドキュメントから
- [Paxos PYUSD Documentation](https://docs.paxos.com/en/pyusd)を確認
- Testnetセクションでアドレスを確認

#### Option B: ブロックエクスプローラーで検索
- [Arbiscan Arbitrum Sepolia](https://sepolia.arbiscan.io/)
- "PYUSD"で検索
- テストネットトークンコントラクトを特定

### 3. コンパイルとテスト

```bash
# コンパイル
npm run compile

# テスト実行
npm test
```

### 4. ローカルネットワークでのテスト

```bash
# Hardhatローカルネットワーク起動
npx hardhat node

# 別のターミナルでデプロイ
npx hardhat run scripts/deploy.js --network localhost
```

### 5. テストネットへのデプロイ

```bash
# Arbitrum Sepoliaへデプロイ
npm run deploy:arbitrum
```

## 必要なリソース

### 1. PYUSDテストネットトークン
- **Google Cloud Faucet**: PYUSDテストトークンの提供
- **Paxos Faucet**: 公式フォーセット

### 2. テストネットETH
- **Arbitrum Sepolia Faucet**: [Alchemy](https://www.alchemy.com/faucets/arbitrum-sepolia)
- **Sepolia Faucet**: [Chainlink Faucet](https://faucets.chain.link/)

### 3. API キー（オプション）
- **Arbiscan**: コントラクト検証用
- **Etherscan**: コントラクト検証用
- **Infura/Alchemy**: RPC URL用

## トラブルシューティング

### 問題: Node.jsバージョンが古い
```bash
# Node.jsのアップグレード
npm install -g n
sudo n lts
```

### 問題: コンパイルエラー
```bash
# キャッシュクリア
npm run clean
npm install
npm run compile
```

### 問題: PYUSDアドレスが見つからない
- 一時的にモックアドレスを使用してローカルテストを実行可能
- 実際のデプロイ前に正確なアドレスを取得

## 次のステップ

実装は完了しています。以下のステップで完了できます：

1. ✅ PYUSDテストネットアドレスの確認
2. ✅ `.env`ファイルの設定
3. ✅ コンパイルとテスト
4. ✅ テストネットへのデプロイ
5. ✅ フロントエンドの接続とテスト

## サポート

質問がある場合は、以下のリソースを参照してください：
- [README.md](README.md) - プロジェクト概要
- [DEPLOYMENT.md](DEPLOYMENT.md) - 詳細なデプロイ手順
- [ARCHITECTURE.md](ARCHITECTURE.md) - アーキテクチャ説明
