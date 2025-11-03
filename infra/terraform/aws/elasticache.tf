# ElastiCache Redis
# マネージドキャッシュを使用せず、VM内のDockerコンテナでRedisを実行
# コストを抑えるため、ElastiCacheはコメントアウト

# # ElastiCache Subnet Group
# resource "aws_elasticache_subnet_group" "dify" {
#   name       = "${var.prefix}-${var.environment}-cache-subnet-group"
#   subnet_ids = aws_subnet.private[*].id

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.prefix}-${var.environment}-cache-subnet-group"
#     }
#   )
# }

# # ElastiCache Parameter Group
# resource "aws_elasticache_parameter_group" "dify" {
#   name   = "${var.prefix}-${var.environment}-redis-params"
#   family = "redis7"

#   parameter {
#     name  = "maxmemory-policy"
#     value = "allkeys-lru"
#   }

#   tags = local.common_tags
# }

# # ElastiCache Cluster
# resource "aws_elasticache_cluster" "dify" {
#   cluster_id           = "${var.prefix}-${var.environment}-redis"
#   engine               = "redis"
#   engine_version       = "7.0"
#   node_type            = var.elasticache_node_type
#   num_cache_nodes      = var.elasticache_num_cache_nodes
#   parameter_group_name = aws_elasticache_parameter_group.dify.name
#   subnet_group_name    = aws_elasticache_subnet_group.dify.name
#   security_group_ids   = [aws_security_group.elasticache.id]

#   port = 6379

#   snapshot_retention_limit = var.environment == "prod" ? 7 : 0
#   snapshot_window          = "03:00-05:00"
#   maintenance_window       = "mon:05:00-mon:07:00"

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.prefix}-${var.environment}-redis"
#     }
#   )
# }
