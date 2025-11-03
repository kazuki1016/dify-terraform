# AWS Dify Terraform

このディレクトリには、AWS上でDify環境を構築するためのTerraformコードが含まれています。

## 構成

- `main.tf` - プロバイダー設定とデータソース
- `variables.tf` - 変数定義
- `terraform.tfvars` - 変数の値
- `network.tf` - VPC、サブネット、ルーティング
- `security_groups.tf` - セキュリティグループ
- `ec2.tf` - EC2インスタンス
- `rds.tf` - RDS PostgreSQL
- `elasticache.tf` - ElastiCache Redis
- `s3.tf` - S3バケット
- `secrets.tf` - SSH鍵とSecrets Manager
- `output.tf` - 出力値
- `user_data.sh` - EC2初期化スクリプト
- `templates/hosts.ini.tpl` - Ansibleインベントリテンプレート

## 前提条件

1. Terraform 1.6.0以上
2. AWS CLI設定済み
3. 適切なIAM権限

## 初回セットアップ

### 1. S3バックエンドの作成（オプション）

```bash
# S3バケット作成
aws s3 mb s3://dify-terraform-state --region ap-northeast-1

# バージョニング有効化
aws s3api put-bucket-versioning \
  --bucket dify-terraform-state \
  --versioning-configuration Status=Enabled

# 暗号化有効化
aws s3api put-bucket-encryption \
  --bucket dify-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# DynamoDBテーブル作成（ロック用）
aws dynamodb create-table \
  --table-name dify-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-1
```

S3バックエンドを使用しない場合は、`main.tf`の`backend "s3"`ブロックをコメントアウトしてください。

### 2. 変数の設定

`terraform.tfvars`を編集して、環境に合わせて値を変更します：

```hcl
aws_region  = "ap-northeast-1"
environment = "dev"
prefix      = "dify"

# 必要に応じて他の値も変更
```

## デプロイ

### 初期化

```bash
terraform init
```

### プランの確認

```bash
terraform plan
```

### 適用

```bash
terraform apply
```

### リソースの確認

```bash
# 出力値の表示
terraform output

# SSH接続コマンドの表示
terraform output -raw ssh_command
```

## リソース削除

```bash
terraform destroy
```

## セキュリティ注意事項

1. **Secrets Manager**: 機密情報は自動的にSecrets Managerに保存されます
2. **暗号化**: RDS、S3、EBSはすべて暗号化されています
3. **ネットワーク**: データベースはプライベートサブネットに配置されます
4. **SSH鍵**: 自動生成されたSSH鍵はローカルとSecrets Managerに保存されます

## トラブルシューティング

### エラー: "Error creating DB Instance: DBSubnetGroupNotFoundFault"

サブネットグループの作成に時間がかかる場合があります。再度`terraform apply`を実行してください。

### エラー: "Error creating ElastiCache Cluster: SubnetGroupNotFoundFault"

同様に、再度`terraform apply`を実行してください。

### SSH接続できない

1. セキュリティグループを確認
2. Elastic IPが正しく割り当てられているか確認
3. SSH鍵のパーミッションを確認: `chmod 600 ../ansible/aws/ec2_ssh_key.pem`

## コスト最適化

開発環境でコストを削減するには、`terraform.tfvars`で以下を変更：

```hcl
ec2_instance_type           = "t3.small"
rds_instance_class          = "db.t3.micro"
elasticache_node_type       = "cache.t3.micro"
rds_backup_retention_period = 1
```

## 参考リンク

- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Dify Documentation](https://docs.dify.ai/)
