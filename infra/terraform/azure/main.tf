# TerraformとAzureプロバイダーの設定
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
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
}

provider "azurerm" {
  features {
  }
  skip_provider_registration = true
  tenant_id                  = var.tenant_id
  subscription_id            = var.subscription_id
  client_id                  = var.client_id
  client_secret              = var.client_secret
}

# ----------------------------------------------------------------
# データソース定義
# ----------------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "manage_rg" {
  name = var.manage_resource_group_name
}

data "azurerm_resource_group" "app_rg" {
  name = var.app_resource_group_name
}

# ----------------------------------------------------------------
# ローカル変数定義
# ----------------------------------------------------------------
locals {
  common_tags = {
    System      = "Dify"
    Environment = "Prod"
  }
}
