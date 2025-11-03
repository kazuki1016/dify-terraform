# TerraformとAWSプロバイダーの設定
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }

  # S3バックエンドの設定 (オプション)
  backend "s3" {
    bucket         = "dify-terraform-state"
    key            = "dify/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "dify-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# ----------------------------------------------------------------
# データソース定義
# ----------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# 最新のUbuntu 22.04 LTS AMIを取得
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ----------------------------------------------------------------
# ローカル変数定義
# ----------------------------------------------------------------
locals {
  common_tags = {
    System      = "Dify"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "dify-pokemon"
  }

  # アベイラビリティゾーンの選択
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}
