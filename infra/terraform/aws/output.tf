# Outputs

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "ec2_public_ip" {
  value       = aws_eip.ec2.public_ip
  description = "EC2インスタンスのパブリックIPアドレス"
}

output "ec2_instance_id" {
  value       = aws_instance.dify.id
  description = "EC2インスタンスID"
}

output "security_group_id" {
  value       = aws_security_group.ec2.id
  description = "EC2セキュリティグループID"
}

# RDSとElastiCacheを使用しないため、これらの出力をコメントアウト
# output "rds_endpoint" {
#   value       = aws_db_instance.dify.endpoint
#   description = "RDSエンドポイント"
# }

# output "rds_database_name" {
#   value       = aws_db_instance.dify.db_name
#   description = "RDSデータベース名"
# }

# output "redis_endpoint" {
#   value       = aws_elasticache_cluster.dify.cache_nodes[0].address
#   description = "Redisエンドポイント"
# }

# output "redis_port" {
#   value       = aws_elasticache_cluster.dify.cache_nodes[0].port
#   description = "Redisポート番号"
# }

output "s3_bucket_name" {
  value       = aws_s3_bucket.dify.id
  description = "S3バケット名"
}

output "ssh_command" {
  value       = "ssh -i ../ansible/aws/ec2_ssh_key.pem ubuntu@${aws_eip.ec2.public_ip}"
  description = "EC2インスタンスへのSSH接続コマンド"
  sensitive   = true
}

output "dify_url" {
  value       = "http://${aws_eip.ec2.public_ip}"
  description = "DifyアプリケーションURL"
}

# output "secrets_manager_rds_credentials_arn" {
#   value       = aws_secretsmanager_secret.rds_credentials.arn
#   description = "RDS認証情報のSecrets Manager ARN"
#   sensitive   = true
# }

output "secrets_manager_ssh_private_key_arn" {
  value       = aws_secretsmanager_secret.ssh_private_key.arn
  description = "SSH秘密鍵のSecrets Manager ARN"
  sensitive   = true
}
