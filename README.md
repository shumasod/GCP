# GCP AppEngine アプリケーション移行ガイド

## 用途
既存のAppEngineアプリケーションを新しいGCPプロジェクトへ移行する際の手順書

## 必要な準備
- GCloud SDK
- Git
- 適切なIAM権限
- 移行元プロジェクトのソースコード

## 移行手順

### 1. アプリケーション準備
```bash
# ソースコード取得
git clone https://github.com/your-repo/app.git && cd app

# 新規プロジェクト作成
gcloud app create --region=asia-northeast1 --project=new-project-id
```

### 2. デプロイと設定
```bash
# アプリケーションのデプロイ
gcloud app deploy --project=new-project-id

# サービスアカウント設定
gcloud iam service-accounts create app-sa \
    --display-name="AppEngine SA" \
    --project=new-project-id
```

### 3. データ移行（必要な場合）
```bash
# Datastore データ移行
gcloud datastore export \
    --kinds=YourKind \
    --project=old-project-id \
    gs://bucket/export/

gcloud datastore import \
    --kinds=YourKind \
    --project=new-project-id \
    gs://bucket/export/
```

## 確認事項
- [ ] 環境変数の更新
- [ ] APIキーの設定
- [ ] Firebaseの再連携
- [ ] カスタムドメインの設定

## トラブルシューティング
```bash
# ログ確認
gcloud app logs tail --project=new-project-id

# サービス状態確認
gcloud app services list --project=new-project-id
```

## 注意点
- デプロイ前に`app.yaml`の確認
- 移行前のデータバックアップ
- 新環境でのテスト実施


このケースは以下のようなシナリオを想定しています：

1. 既存のAppEngineアプリケーションがあり、新しいGCPプロジェクトへ移行が必要な場合
2. 以下のような状況での使用：
   - プロジェクトの再編成
   - 開発環境から本番環境への移行
   - 組織変更に伴うプロジェクト移行
   - リソース最適化のための環境統合

修正のポイント：
1. チェックリスト形式の採用
2. 重要コマンドの厳選
3. 手順の簡略化と明確化
4. トラブルシューティングセクションの追加

必要に応じて、さらなる具体的なユースケースや手順の詳細化も可能です。ご要望がありましたらお知らせください。
## 概要
このガイドでは、既存のAppEngineアプリケーションを新しいGCPプロジェクトへ移行する手順を説明します。

## 前提条件
- GCPアカウントと適切な権限
- Google Cloud SDK（gcloudコマンド）のインストール
- Git（ソースコード管理を使用する場合）

## 手順

### 1. ソースコードの取得
```bash
# プロジェクトディレクトリの作成
mkdir migration-project && cd migration-project

# Gitリポジトリからソースコードを取得
git clone https://github.com/your-repo/existing-app.git
```

### 2. 新規プロジェクトのセットアップ
```bash
# プロジェクトの切り替え
gcloud config set project new-project-id

# AppEngineアプリケーションの作成
gcloud app create --region=asia-northeast1
```

### 3. アプリケーションのデプロイ
```bash
cd existing-app

# app.yamlの確認と必要に応じた修正
# デプロイの実行
gcloud app deploy --project=new-project-id --quiet
```

### 4. データの移行
#### Cloud Datastoreの場合
```bash
# データのエクスポート
gcloud datastore export \
  --kinds=YourKind \
  --project=old-project-id \
  --destination-format=json \
  gs://your-bucket/export/

# データのインポート
gcloud datastore import \
  --kinds=YourKind \
  --project=new-project-id \
  gs://your-bucket/export/
```

### 5. 認証設定
1. サービスアカウントの設定
```bash
# サービスアカウントの作成
gcloud iam service-accounts create app-engine-sa \
  --display-name="AppEngine Service Account"

# 必要な権限の付与
gcloud projects add-iam-policy-binding new-project-id \
  --member="serviceAccount:app-engine-sa@new-project-id.iam.gserviceaccount.com" \
  --role="roles/datastore.user"
```

2. 環境変数の設定
```bash
# サービスアカウントキーの作成
gcloud iam service-accounts keys create key.json \
  --iam-account=app-engine-sa@new-project-id.iam.gserviceaccount.com

# AppEngineへの環境変数設定
gcloud app deploy app.yaml --quiet
```

## 注意点
- データ移行前にバックアップを必ず作成すること
- 環境変数やAPIキーの更新を忘れずに行うこと
- 新環境でのテストを十分に実施すること

## トラブルシューティング
- デプロイエラーの場合: ログを確認（`gcloud app logs tail`）
- 権限エラーの場合: IAM設定を確認
- データ移行エラーの場合: バケットの権限を確認
