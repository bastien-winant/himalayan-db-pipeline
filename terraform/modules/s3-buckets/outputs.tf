output "data_bucket_name" {
  description = "Name of the created S3 data bucket"
  value       = aws_s3_bucket.data.id
}

output "data_bucket_arn" {
  description = "ARN of the created S3 data bucket"
  value       = aws_s3_bucket.data.arn
}

output "artifacts_bucket_name" {
  description = "Name of the created S3 artifacts bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "artifacts_bucket_arn" {
  description = "ARN of the created S3 artifacts bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "logs_bucket_name" {
  description = "Name of the created S3 access logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "ARN of the created S3 access logs bucket"
  value       = aws_s3_bucket.logs.arn
}