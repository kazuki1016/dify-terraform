# EC2インスタンス

# Elastic IP for EC2
resource "aws_eip" "ec2" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix}-${var.environment}-ec2-eip"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# EC2 Key Pair
resource "aws_key_pair" "dify" {
  key_name   = "${var.prefix}-${var.environment}-key"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix}-${var.environment}-keypair"
    }
  )
}

# IAM Role for EC2
resource "aws_iam_role" "ec2" {
  name = "${var.prefix}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Role Policy for CloudWatch Logs
resource "aws_iam_role_policy" "ec2_cloudwatch" {
  name = "cloudwatch-logs"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM Role Policy for S3 Access
resource "aws_iam_role_policy" "ec2_s3" {
  name = "s3-access"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.dify.arn,
          "${aws_s3_bucket.dify.arn}/*"
        ]
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.prefix}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = local.common_tags
}

# EC2 Instance
resource "aws_instance" "dify" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.dify.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.ec2_root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.prefix}-${var.environment}-root-volume"
      }
    )
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = var.ec2_data_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.prefix}-${var.environment}-data-volume"
      }
    )
  }

  # マネージドサービス(RDS/ElastiCache)を使用しない構成
  # DifyのDocker Compose内のPostgreSQLとRedisを使用
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    s3_bucket   = aws_s3_bucket.dify.id
    aws_region  = var.aws_region
    environment = var.environment
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix}-${var.environment}-ec2"
    }
  )

  # マネージドサービスを使用しないため、依存関係を削除
  # depends_on = [
  #   aws_db_instance.dify,
  #   aws_elasticache_cluster.dify
  # ]
}

# Associate Elastic IP with EC2
resource "aws_eip_association" "ec2" {
  instance_id   = aws_instance.dify.id
  allocation_id = aws_eip.ec2.id
}

# CloudWatch Log Group for EC2
resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/${var.prefix}-${var.environment}"
  retention_in_days = 7

  tags = local.common_tags
}
