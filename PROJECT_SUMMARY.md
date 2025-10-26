# PYUSD Subscription Service - Project Summary

## プロジェクト概要

PYUSD（PayPal USD）を利用した、次世代の分散型サブスクリプションサービスです。スマートコントラクトとフロントエンドインターフェースを統合し、迅速性、低コスト、24時間365日の利用可能性を特徴とする革新的な決済体験を提供します。

## 実装済み機能

### 1. スマートコントラクト (Solidity)

#### 主要コントラクト

**PYUSDSubscription.sol**
- プラン管理機能（料金設定、期間設定）
- 購読開始/更新機能
- アクセス管理（isSubscribed関数）
- 自動支払いメカニズム（Programmable Payment Logic）
- 返金/解約機能
- ERC20 Permit対応（ガスレス承認）
- OpenZeppelinのセキュリティ機能（ReentrancyGuard, Pausable, Ownable）

**IPYUSD.sol**
- PYUSDトークンインターフェース
- ERC20標準関数
- EIP-2612 Permit機能

### 2. フロントエンド (Next.js)

**技術スタック:**
- Next.js 16
- React 18
- ethers.js v6
- Tailwind CSS（Next.js内で設定）

**主要機能:**
- MetaMaskウォレット接続
- サブスクリプション管理UI
- トランザクション処理
- レスポンシブデザイン

### 3. デプロイメント & テスト

- Hardhat開発環境
- 包括的なテストスイート
- 自動デプロイメントスクリプト
- コントラクト検証対応

## ファイル構成

```
subscryption/
├── contracts/
│   ├── PYUSDSubscription.sol    # メインサブスクリプションコントラクト
│   └── IPYUSD.sol               # PYUSDトークンインターフェース
├── test/
│   └── PYUSDSubscription.test.js
├── scripts/
│   └── deploy.js               # デプロイメントスクリプト
├── frontend/
│   ├── app/
│   │   ├── layout.js           # Next.jsレイアウト
│   │   └── page.js             # メインページ
│   ├── next.config.js          # Next.js設定
│   └── package.json            # フロントエンド依存関係
├── hardhat.config.js           # Hardhat設定
├── package.json                # プロジェクト依存関係
├── README.md                   # プロジェクト説明
├── DEPLOYMENT.md               # デプロイメントガイド
├── ARCHITECTURE.md             # アーキテクチャドキュメント
└── PROJECT_SUMMARY.md          # このファイル
```

## 主要機能の詳細

### 料金設定機能 (Price Setup)

```solidity
function createPlan(
    string memory name,
    uint256 price,
    uint256 billingPeriod,
    uint256 maxSubscribers
) external onlyOwner returns (uint256)
```

- サービス提供者がPYUSD単位で月額料金を設定
- 期間（例：30日）を柔軟に設定可能
- マイクロトランザクションや従量課金制をサポート

### 購読開始/更新機能 (Subscribe/Renew)

**標準購読:**
```solidity
function subscribe(uint256 planId) external nonReentrant whenNotPaused
```

**Permit機能を使用した購読（ガスレス）:**
```solidity
function subscribeWithPermit(
    uint256 planId,
    uint8 v,
    bytes32 r,
    bytes32 s,
    uint256 deadline
) external nonReentrant whenNotPaused
```

**自動更新:**
```solidity
function processPayment(address subscriber) external nonReentrant onlyAuthorizedPuller
```

### アクセス管理 (Access Control)

```solidity
function isSubscribed(address user) external view returns (bool)
```

- 特定のウォレットアドレスがアクティブなサブスクリプションを持っているかをチェック
- 有効期限の自動チェック

### 自動支払いメカニズム (Programmable Payment Logic)

PYUSDのプログラマビリティを活用：
- ユーザーが一度承認すれば、サービス提供者が定期的にトークンを引き落とし可能
- ERC20 Permitを利用した革新的な支払いロジック
- ACHや電信送金に代わる効率的な新方法

### 返金/解約機能 (Refund/Cancel)

```solidity
function cancelSubscription() external nonReentrant
```

- ユーザーがいつでも購読を停止可能
- 即座に有効化状態が変更される

## セキュリティ機能

### コントラクトセキュリティ

1. **ReentrancyGuard**: リエントランシー攻撃の防止
2. **Pausable**: 緊急時の一時停止機能
3. **Ownable**: 所有者のみが実行可能な関数
4. **SafeMath**: 算術演算のオーバーフロー保護
5. **入力検証**: すべての入力パラメータを検証

### フロントエンドセキュリティ

1. 環境変数による機密情報管理
2. トランザクション検証
3. エラーハンドリング
4. ウォレット認証

## デプロイメント方法

### 1. 環境セットアップ

```bash
# 依存関係のインストール
npm install

# .envファイルの作成
PRIVATE_KEY=your_private_key
PYUSD_ADDRESS=0x... # テストネットのPYUSDアドレス
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ARBISCAN_API_KEY=your_api_key
```

### 2. コンパイル

```bash
npm run compile
```

### 3. テスト

```bash
npm test
```

### 4. デプロイ

```bash
# Arbitrum Sepoliaへデプロイ
npm run deploy:arbitrum

# または
npx hardhat run scripts/deploy.js --network arbitrumSepolia
```

### 5. フロントエンド起動

```bash
cd frontend
npm install
npm run dev
# http://localhost:3000 でアクセス
```

## PYUSDアドレス

### テストネット

**Arbitrum Sepolia:**
```
PYUSD: 0x... (実アドレスに更新が必要)
```

**Ethereum Sepolia:**
```
PYUSD: 0x... (実アドレスに更新が必要)
```

### PYUSDテストネットトークンの取得

- Google Cloud Faucet
- Paxos Faucet

## 使用例

### フロントエンドから購読する

```javascript
// ウォレット接続
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();

// PYUSDの承認
const pyusdContract = new ethers.Contract(pyusdAddress, pyusdAbi, signer);
await pyusdContract.approve(contractAddress, planPrice);

// 購読
const contract = new ethers.Contract(contractAddress, contractAbi, signer);
await contract.subscribe(planId);
```

### Permitを使用した購読（ガスレス）

```javascript
// EIP-2612 Permit署名の作成
const domain = { /* ... */ };
const types = { /* ... */ };
const value = { /* ... */ };
const signature = await signer.signTypedData(domain, types, value);
const { r, s, v } = ethers.Signature.from(signature);

// Permitで購読
await contract.subscribeWithPermit(planId, v, r, s, deadline);
```

## 技術的な特徴

### PYUSDの活用

1. **プログラマビリティ**: スマートコントラクトで制御可能
2. **即時決済**: ブロックチェーン上で瞬時に決済完了
3. **低コスト**: ガス代が安い（特にArbitrum上）
4. **24/7利用可能**: 銀行営業時間の制約なし
5. **グローバルアクセス**: どこからでもアクセス可能

### イノベーション

1. **分散型サブスクリプション**: 中央集権的な決済処理者不要
2. **自動更新機能**: 手動操作不要の自動課金
3. **透明性**: すべての取引がブロックチェーン上で記録
4. **国際決済**: 為替レートや国際送金手数料の問題を回避

## 今後の拡張案

1. **ストリーミング決済**: 時間単位での自動課金
2. **複数トークン対応**: 他のステーブルコインのサポート
3. **部分返金システム**: 未使用期間への返金
4. **アナリティクスダッシュボード**: 収益追跡、ユーザー分析
5. **NFT統合**: サブスクリプションNFTの発行

## ドキュメント

- **README.md**: プロジェクトの概要と基本的な使用方法
- **DEPLOYMENT.md**: 詳細なデプロイメントガイド
- **ARCHITECTURE.md**: システムアーキテクチャの詳細説明
- **PROJECT_SUMMARY.md**: このファイル（プロジェクト全体のサマリー）

## ライセンス

MIT License

## まとめ

このプロジェクトは、PYUSDを核とした次世代の分散型サブスクリプションサービスを実装しています。従来の決済システムが抱える課題（決済に日数がかかる、中間手数料、銀行営業時間による制約など）を解決し、迅速性、低コスト、24時間365日の利用可能性を特徴とする革新的な消費者向け決済体験を提供します。

## 技術スタック

**バックエンド:**
- Solidity 0.8.24
- OpenZeppelin Contracts
- Hardhat

**フロントエンド:**
- Next.js 16
- React 18
- ethers.js v6

**テストネット:**
- Arbitrum Sepolia（推奨）
- Ethereum Sepolia

## 連絡先

質問やコントリビューションは歓迎します。詳細はREADME.mdを参照してください。
