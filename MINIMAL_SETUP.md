# 最小限のセットアップ - Minimal Setup

## 必要なもの

デプロイに必要なのは**2つだけ**です：

1. **PRIVATE_KEY**: デプロイ用ウォレットの秘密鍵
2. **PYUSD_ADDRESS**: PYUSDトークンのコントラクトアドレス

## クイックセットアップ

### Step 1: .envファイルの編集

```bash
nano .env
```

以下の2行だけ設定してください：

```env
PRIVATE_KEY=0x... # あなたの秘密鍵
PYUSD_ADDRESS=0x... # PYUSDのアドレス
```

### Step 2: PYUSDアドレスの取得方法

トランザクション: https://sepolia.etherscan.io/tx/0xbc5c4b5de28ff5197fcdd2b88602b76242469a46d3d33b98de67f8924cbb1320

1. 上記リンクを開く
2. "To" または "Token Transfer" セクションを見る
3. PYUSDコントラクトアドレスをコピー

または、トランザクションの中で`0x`で始まる長いアドレス（ETHアドレス以外）を見つけてください。それがPYUSDアドレスです。

### Step 3: 秘密鍵の取得

- MetaMaskからエクスポート
- または新しいテストウォレットを作成

### Step 4: デプロイ

```bash
# コンパイル
npm run compile

# デプロイ（Ethereum Sepolia）
npm run deploy:sepolia
```

## その他の設定（オプション）

RPC URL、APIキーなどは**オプション**です：
- デフォルトでパブリックRPCが使用されます
- APIキーはコントラクト検証時のみ必要

## トラブルシューティング

### "Insufficient funds"
→ Sepolia ETHが必要です: https://faucets.chain.link/

### "Invalid address"
→ PYUSD_ADDRESSが正しく設定されているか確認

### "Invalid private key"
→ PRIVATE_KEYの先頭に`0x`が付いているか確認
