# AWS リージョン設定
variable "aws_region" {
  type        = string
  description = "AWSリージョン"
  default     = "ap-northeast-1"
}

# 環境設定
variable "environment" {
  type        = string
  description = "環境名 (dev/staging/prod)"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "環境は dev, staging, prod のいずれかである必要があります。"
  }
}

# プレフィックス設定
variable "prefix" {
  type        = string
  description = "作成するリソース名の接頭辞"
  default     = "dify"
}

# ネットワーク設定
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDRブロック"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "パブリックサブネットのCIDRブロック"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "プライベートサブネットのCIDRブロック"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# 許可するIPアドレス
variable "allowed_ip_addresses" {
  type        = list(string)
  description = "HTTPアクセスを許可するIPアドレスのリスト (CIDR形式)"
  default     = ["0.0.0.0/0"]
}

# EC2インスタンス設定
variable "ec2_instance_type" {
  type        = string
  description = "EC2インスタンスタイプ"
  default     = "t3.medium"
}

variable "ec2_root_volume_size" {
  type        = number
  description = "EC2ルートボリュームサイズ (GB)"
  default     = 30
}

variable "ec2_data_volume_size" {
  type        = number
  description = "EC2データボリュームサイズ (GB)"
  default     = 50
}

# RDS設定
variable "rds_instance_class" {
  type        = string
  description = "RDSインスタンスクラス"
  default     = "db.t3.small"
}

variable "rds_allocated_storage" {
  type        = number
  description = "RDS割り当てストレージ (GB)"
  default     = 20
}

variable "rds_database_name" {
  type        = string
  description = "RDSデータベース名"
  default     = "dify"
}

variable "rds_username" {
  type        = string
  description = "RDSマスターユーザー名"
  default     = "difyuser"
}

variable "rds_backup_retention_period" {
  type        = number
  description = "RDSバックアップ保持期間 (日)"
  default     = 7
}

# ElastiCache設定
variable "elasticache_node_type" {
  type        = string
  description = "ElastiCacheノードタイプ"
  default     = "cache.t3.micro"
}

variable "elasticache_num_cache_nodes" {
  type        = number
  description = "ElastiCacheノード数"
  default     = 1
}

# S3設定
variable "s3_bucket_name" {
  type        = string
  description = "S3バケット名 (空の場合は自動生成)"
  default     = ""
}

# タグ設定
variable "additional_tags" {
  type        = map(string)
  description = "追加のリソースタグ"
  default     = {}
}
