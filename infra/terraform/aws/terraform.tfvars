# AWS リージョン設定
aws_region = "ap-northeast-1"

# 環境設定
environment = "dev"

# プレフィックス設定
prefix = "dify"

# ネットワーク設定
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# 許可するIPアドレス (必要に応じて変更してください)
allowed_ip_addresses = ["0.0.0.0/0"]

# EC2インスタンス設定
ec2_instance_type    = "t3.medium"
ec2_root_volume_size = 30
ec2_data_volume_size = 50

# RDS設定
rds_instance_class          = "db.t3.small"
rds_allocated_storage       = 20
rds_database_name           = "dify"
rds_username                = "difyuser"
rds_backup_retention_period = 7

# ElastiCache設定
elasticache_node_type       = "cache.t3.micro"
elasticache_num_cache_nodes = 1

# S3設定 (空の場合は自動生成)
s3_bucket_name = ""

# 追加タグ
additional_tags = {
  Owner = "DevOps Team"
}
