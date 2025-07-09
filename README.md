# GCP AppEngine アプリケーション移行ガイド

## 1. 概要
既存のAppEngineアプリケーションを新しいGCPプロジェクトへ安全に移行するための完全ガイド

## 2. 前提条件
- [ ] GCPアカウントと適切なIAM権限
- [ ] Google Cloud SDK（gcloudコマンド）のインストール
- [ ] Git（ソースコード管理を使用する場合）
- [ ] 移行元プロジェクトへのアクセス権限
- [ ] 移行先プロジェクトの作成権限

## 3. 移行前準備

### 3.1 現在の環境の確認
```bash
# 移行元プロジェクトの情報取得
gcloud config set project old-project-id
gcloud app describe
gcloud app services list
gcloud app versions list
```

### 3.2 データバックアップ
```bash
# Datastore バックアップ
gcloud datastore export \
    --project=old-project-id \
    --destination-format=json \
    gs://backup-bucket/backup-$(date +%Y%m%d)/

# Storage バックアップ（必要に応じて）
gsutil -m cp -r gs://old-bucket/* gs://backup-bucket/storage-backup/
```

## 4. 移行手順

### 4.1 ソースコードの準備
```bash
# プロジェクトディレクトリの作成
mkdir migration-project && cd migration-project

# ソースコードの取得
git clone https://github.com/your-repo/existing-app.git
cd existing-app
```

### 4.2 新規プロジェクトのセットアップ
```bash
# プロジェクトの切り替え
gcloud config set project new-project-id

# AppEngineアプリケーションの作成
gcloud app create --region=asia-northeast1

# 必要なAPIの有効化
gcloud services enable appengine.googleapis.com
gcloud services enable datastore.googleapis.com
```

### 4.3 設定ファイルの更新
```bash
# app.yamlの環境変数を新プロジェクト用に更新
# 例:
# env_variables:
#   PROJECT_ID: "new-project-id"
#   DATABASE_URL: "new-database-url"
```

### 4.4 サービスアカウントの設定
```bash
# サービスアカウントの作成
gcloud iam service-accounts create app-engine-sa \
    --display-name="AppEngine Service Account" \
    --project=new-project-id

# 必要な権限の付与
gcloud projects add-iam-policy-binding new-project-id \
    --member="serviceAccount:app-engine-sa@new-project-id.iam.gserviceaccount.com" \
    --role="roles/datastore.user"

gcloud projects add-iam-policy-binding new-project-id \
    --member="serviceAccount:app-engine-sa@new-project-id.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"
```

### 4.5 データの移行
```bash
# Datastore データの移行
gcloud datastore export \
    --kinds=YourKind \
    --project=old-project-id \
    --destination-format=json \
    gs://migration-bucket/export/

gcloud datastore import \
    --kinds=YourKind \
    --project=new-project-id \
    gs://migration-bucket/export/

# インデックスの移行
gcloud datastore indexes create index.yaml --project=new-project-id
```

### 4.6 アプリケーションのデプロイ
```bash
# テストデプロイ（本番トラフィックを受けない）
gcloud app deploy --project=new-project-id --no-promote --version=test

# 検証後、本番デプロイ
gcloud app deploy --project=new-project-id --promote
```

## 5. 検証とテスト

### 5.1 デプロイ確認
```bash
# サービス状態確認
gcloud app services list --project=new-project-id
gcloud app versions list --project=new-project-id

# アプリケーションの動作確認
curl -I https://new-project-id.appspot.com/
```

### 5.2 データ整合性確認
```bash
# データ件数の確認
gcloud datastore export \
    --kinds=YourKind \
    --project=new-project-id \
    --destination-format=json \
    gs://verification-bucket/verification/

# 移行前後のデータ比較
```

### 5.3 機能テスト
- [ ] 主要機能の動作確認
- [ ] 認証・認可の確認
- [ ] 外部API連携の確認
- [ ] パフォーマンステスト

## 6. トラブルシューティング

### 6.1 デプロイエラー
```bash
# ログ確認
gcloud app logs tail --project=new-project-id

# 詳細なログ確認
gcloud app logs read --project=new-project-id --limit=100
```

### 6.2 権限エラー
```bash
# IAM設定確認
gcloud projects get-iam-policy new-project-id

# サービスアカウント確認
gcloud iam service-accounts list --project=new-project-id
```

### 6.3 データ移行エラー
```bash
# データストア操作権限確認
gcloud projects add-iam-policy-binding new-project-id \
    --member="user:your-email@example.com" \
    --role="roles/datastore.owner"

# バケット権限確認
gsutil iam get gs://migration-bucket
```

## 7. ロールバック手順

### 7.1 緊急時のロールバック
```bash
# 旧バージョンへの即座の切り替え
gcloud app services set-traffic default --splits=old-version=1.0 \
    --project=old-project-id

# DNS設定の復元（カスタムドメイン使用時）
```

### 7.2 データの復元
```bash
# バックアップからのデータ復元
gcloud datastore import \
    --kinds=YourKind \
    --project=old-project-id \
    gs://backup-bucket/backup-YYYYMMDD/
```

## 8. 移行後の設定

### 8.1 カスタムドメインの設定
```bash
# ドメインマッピングの作成
gcloud app domain-mappings create your-domain.com \
    --project=new-project-id
```

### 8.2 SSL証明書の設定
```bash
# SSL証明書の確認
gcloud app ssl-certificates list --project=new-project-id
```

### 8.3 監視とアラートの設定
```bash
# Cloud Monitoring の設定
gcloud alpha monitoring policies create --policy-from-file=monitoring-policy.yaml
```

## 9. 注意事項

- **データ移行前には必ずバックアップを作成すること**
- **環境変数やAPIキーの更新を忘れずに行うこと**
- **新環境でのテストを十分に実施すること**
- **移行中はサービスの停止時間を最小化すること**
- **ロールバック手順を事前に確認しておくこと**

## 10. チェックリスト

### 移行前
- [ ] 現在の環境の完全バックアップ
- [ ] 移行計画の策定
- [ ] 関係者への事前通知
- [ ] 移行リハーサルの実施

### 移行中
- [ ] 各手順の完了確認
- [ ] エラーログの監視
- [ ] データ整合性の確認
- [ ] 機能テストの実施

### 移行後
- [ ] 本番環境での動作確認
- [ ] 監視設定の確認
- [ ] 旧環境のクリーンアップ
- [ ] 移行報告書の作成
