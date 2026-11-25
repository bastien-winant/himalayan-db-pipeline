output "ingest_function_arn" {
  description = "ARN of the Lambda ingestion function"
  value = aws_lambda_function.ingest.arn
}