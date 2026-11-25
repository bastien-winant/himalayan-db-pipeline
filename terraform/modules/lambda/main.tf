locals {
  function_name    = "${var.name_prefix}-ingest"
  lambda_dir       = "${path.root}/../src/himalayan_db_pipeline/lambda"
  pandas_layer_arn = "arn:aws:lambda:eu-central-1:336392948345:layer:AWSSDKPandas-Python314:12"
}

resource "aws_cloudwatch_log_group" "ingest_log_group" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}

# Package the Lambda function code
data "archive_file" "file" {
  type        = "zip"
  source_file = "${local.lambda_dir}/function/ingest.py"
  output_path = "${local.lambda_dir}/function/function.zip"
}

# Lambda function
resource "aws_lambda_function" "ingest" {
  filename      = data.archive_file.file.output_path
  function_name = local.function_name
  role          = var.lambda_role_arn
  handler       = ingest.lambda_handler
  code_sha256   = data.archive_file.file.output_base64sha256

  runtime       = "python3.14"
  architectures = ["x86_64"]
  memory_size   = 1024
  timeout       = 180

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  # Ensure log group exists before function
  depends_on = [aws_cloudwatch_log_group.ingest_log_group]

  tags = var.tags
}