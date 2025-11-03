# S3 Bucket for Dify uploads

# Random suffix for bucket name
resource "random_id" "s3_suffix" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "dify" {
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.prefix}-${var.environment}-uploads-${random_id.s3_suffix.hex}"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.prefix}-${var.environment}-uploads"
    }
  )
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "dify" {
  bucket = aws_s3_bucket.dify.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dify" {
  bucket = aws_s3_bucket.dify.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "dify" {
  bucket = aws_s3_bucket.dify.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Policy
resource "aws_s3_bucket_lifecycle_configuration" "dify" {
  bucket = aws_s3_bucket.dify.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }

  rule {
    id     = "delete-incomplete-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "dify" {
  bucket = aws_s3_bucket.dify.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
