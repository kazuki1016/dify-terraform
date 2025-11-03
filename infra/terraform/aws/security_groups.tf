# Security Groups

# EC2 Security Group
resource "aws_security_group" "ec2" {
  name        = "${var.prefix}-${var.environment}-ec2-sg"
  description = "Security group for Dify EC2 instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix}-${var.environment}-ec2-sg"
    }
  )
}

# EC2 Security Group Rules - Ingress
resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow HTTP from allowed IPs"

  cidr_ipv4   = var.allowed_ip_addresses[0]
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name = "allow-http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_https" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow HTTPS from allowed IPs"

  cidr_ipv4   = var.allowed_ip_addresses[0]
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name = "allow-https"
  }
}

# EC2 Security Group Rules - Egress
resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "allow-all-outbound"
  }
}

# RDS Security Group (コメントアウト - マネージドデータベースを使用しない)
# resource "aws_security_group" "rds" {
#   name        = "${var.prefix}-${var.environment}-rds-sg"
#   description = "Security group for Dify RDS instance"
#   vpc_id      = aws_vpc.main.id

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.prefix}-${var.environment}-rds-sg"
#     }
#   )
# }

# # RDS Security Group Rules - Ingress
# resource "aws_vpc_security_group_ingress_rule" "rds_postgres" {
#   security_group_id = aws_security_group.rds.id
#   description       = "Allow PostgreSQL from EC2"

#   referenced_security_group_id = aws_security_group.ec2.id
#   from_port                    = 5432
#   to_port                      = 5432
#   ip_protocol                  = "tcp"

#   tags = {
#     Name = "allow-postgres-from-ec2"
#   }
# }

# # ElastiCache Security Group (コメントアウト - マネージドキャッシュを使用しない)
# resource "aws_security_group" "elasticache" {
#   name        = "${var.prefix}-${var.environment}-elasticache-sg"
#   description = "Security group for Dify ElastiCache"
#   vpc_id      = aws_vpc.main.id

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.prefix}-${var.environment}-elasticache-sg"
#     }
#   )
# }

# # ElastiCache Security Group Rules - Ingress
# resource "aws_vpc_security_group_ingress_rule" "elasticache_redis" {
#   security_group_id = aws_security_group.elasticache.id
#   description       = "Allow Redis from EC2"

#   referenced_security_group_id = aws_security_group.ec2.id
#   from_port                    = 6379
#   to_port                      = 6379
#   ip_protocol                  = "tcp"

#   tags = {
#     Name = "allow-redis-from-ec2"
#   }
# }
