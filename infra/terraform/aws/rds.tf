# RDS PostgreSQL
# マネージドデータベースを使用せず、VM内のDockerコンテナでPostgreSQLを実行
# コストを抑えるため、RDSはコメントアウト

# # RDS Subnet Group
# resource "aws_db_subnet_group" "dify" {
#   name       = "${var.prefix}-${var.environment}-db-subnet-group"
#   subnet_ids = aws_subnet.private[*].id

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.prefix}-${var.environment}-db-subnet-group"
#     }
#   )
# }

# # RDS Password
# resource "random_password" "rds" {
#   length  = 32
#   special = true
# }

# # RDS Instance
# resource "aws_db_instance" "dify" {
#   identifier     = "${var.prefix}-${var.environment}-db"
#   engine         = "postgres"
#   engine_version = "15.4"
#   instance_class = var.rds_instance_class

#   allocated_storage     = var.rds_allocated_storage
#   max_allocated_storage = var.rds_allocated_storage * 2
#   storage_type          = "gp3"
#   storage_encrypted     = true

#   db_name  = var.rds_database_name
#   username = var.rds_username
#   password = random_password.rds.result

#   db_subnet_group_name   = aws_db_subnet_group.dify.name
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   publicly_accessible    = false

#   backup_retention_period = var.rds_backup_retention_period
#   backup_window           = "03:00-04:00"
#   maintenance_window      = "mon:04:00-mon:05:00"

#   skip_final_snapshot       = var.environment == "dev" ? true : false
#   final_snapshot_identifier = var.environment == "dev" ? null : "${var.prefix}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

#   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.prefix}-${var.environment}-db"
#     }
#   )
# }

# # Store RDS credentials in Secrets Manager
# resource "aws_secretsmanager_secret" "rds_credentials" {
#   name                    = "${var.prefix}-rds-credentials-${var.environment}"
#   description             = "RDS PostgreSQL credentials for Dify"
#   recovery_window_in_days = 7

#   tags = local.common_tags
# }

# resource "aws_secretsmanager_secret_version" "rds_credentials" {
#   secret_id = aws_secretsmanager_secret.rds_credentials.id
#   secret_string = jsonencode({
#     username = var.rds_username
#     password = random_password.rds.result
#     engine   = "postgres"
#     host     = aws_db_instance.dify.endpoint
#     port     = 5432
#     dbname   = var.rds_database_name
#   })
# }
