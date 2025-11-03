# Azure 認証情報
variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  sensitive   = true
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure Service Principal Client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure Service Principal Client Secret"
  sensitive   = true
}

# リソース設定
variable "manage_resource_group_name" {
  type        = string
  description = "管理リソースを配置する既存のリソースグループ名"
  default     = "${リソースグループ名}"
}

variable "app_resource_group_name" {
  type        = string
  description = "アプリケーションリソースを配置する既存のリソースグループ名"
  default     = "${リソースグループ名}"
}

variable "prefix" {
  type        = string
  description = "作成するリソース名の接頭辞"
  default     = "${VM名}"
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "NSGで許可するIPアドレスのリスト"
  default     = ["xx.xx.xx.xx/xx"]
}

