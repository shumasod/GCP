# GCP AppEngine アプリケーション移行ガイド

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
