# GCP

まず、既存のAppEngineアプリのソースコードをGitリポジトリやZIPファイルから取得します。ここでは、Gitリポジトリから取得する例を示します。

```bash
# 既存アプリのソースコードをクローンする
git clone https://github.com/your-repo/existing-app.git
```

次に、移行先の新しいGCPプロジェクトでAppEngineアプリを作成します。

```bash
# 新しいGCPプロジェクトにAppEngineアプリを作成する
gcloud app create --project=new-project-id
```

作成したAppEngineアプリにソースコードをデプロイします。

```bash
# クローンしたソースコードディレクトリに移動する
cd existing-app

# アプリをデプロイする
gcloud app deploy --project=new-project-id
```

デプロイが完了したら、必要に応じて関連サービスの設定を移行します。例えば、Cloud Datastoreを使用している場合は、次のようにデータをエクスポート/インポートできます。

```bash
# Datastoreのエンティティをエクスポートする
gcloud datastore export --kinds=YourKind --project=old-project-id gs://your-bucket/entities.txt

# エクスポートしたエンティティをインポートする
gcloud datastore import --kinds=YourKind --project=new-project-id gs://your-bucket/entities.txt
```

FirebaseやCloud Storageなど、他の関連サービスについても同様に、設定を新しいプロジェクトに移行する必要があります。

最後に、FirebaseとAppEngineの認証設定とネットワーク設定を行います。詳しい手順は以前説明したとおりです。

- サービスアカウントの作成と権限付与
- Firebaseへのサービスアカウント紐付け  
- AppEngineの環境変数にサービスアカウントキーを設定
- ファイアウォール設定

このように、ソースコードをクローンし、新しいプロジェクトにデプロイすることで、AppEngineアプリを移行できます。関連サービスの設定移行と認証設定が別途必要になる点に注意が必要です。
