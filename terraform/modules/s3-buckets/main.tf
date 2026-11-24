resource "aws_s3_bucket" "data" {
  bucket = "${var.name_prefix}-data-${var.account_id}-${var.aws_region}-an"
  bucket_namespace = "account-regional"
  force_destroy = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "data_access_block" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data_versioning" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}