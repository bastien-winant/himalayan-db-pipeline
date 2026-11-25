locals {
  function_name    = "${var.name_prefix}-ingest"
  lambda_dir       = "${path.root}/../src/himalayan_db_pipeline/lambda"
  pandas_layer_arn = "arn:aws:lambda:eu-central-1:336392948345:layer:AWSSDKPandas-Python314:12"
}

# Cloudwatch group for ingest function calls
resource "aws_cloudwatch_log_group" "ingest_log_group" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.cloudwatch_retention_days

  tags = merge(var.tags, {
    Function = local.function_name
  })
}

# IAM permission for Lambda execution
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

# IAM role for Lambda to assume
resource "aws_iam_role" "lambda_role" {
  name_prefix          = local.function_name
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role.json
  max_session_duration = 3600
  tags                 = var.tags
}

# Policy document for ingest function execution
data "aws_iam_policy_document" "lambda_policy_document" {
  # write logs to Cloudwatch
  statement {
    effect = "Allow"
    resources = ["${aws_cloudwatch_log_group.ingest_log_group.arn}:*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }

  # load files in S3
  statement {
    effect    = "Allow"
    resources = ["${var.data_bucket_arn}/stg/*"]
    actions   = ["s3:PutObject"]
  }
}

resource "aws_iam_role_policy" "ingest_policy" {
  name_prefix = local.function_name
  role        = aws_iam_role.lambda_role.id
  policy      = data.aws_iam_policy_document.lambda_policy_document.json
}
# # Policy from the policy document
# resource "aws_iam_policy" "lambda_policy" {
#   name_prefix = local.function_name
#   policy      = data.aws_iam_policy_document.lambda_assume_role.json
# }

# # Attach the policy to the Lambda execution role
# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_policy.arn
# }

# Package the Layer dependencies
data "archive_file" "dbfread" {
  type        = "zip"
  source_dir  = "${local.lambda_dir}/layer/dbfread"
  output_path = "${local.lambda_dir}/layer/dbfread_layer.zip"
}

# Requests dependencies layer
resource "aws_lambda_layer_version" "dbfread" {
  filename                 = data.archive_file.dbfread.output_path
  layer_name               = "python314-dbfread"
  description              = "dbfread dependency for Lambda functions"
  compatible_runtimes      = ["python3.14"]
  compatible_architectures = ["x86_64", "arm64"]
  source_code_hash         = filebase64sha256(data.archive_file.dbfread.output_path)
}

# Package the Lambda function code
data "archive_file" "ingest" {
  type        = "zip"
  source_file = "${local.lambda_dir}/function/ingest/index.py"
  output_path = "${local.lambda_dir}/function/ingest/function.zip"
}

# Lambda function
resource "aws_lambda_function" "ingest" {
  filename      = data.archive_file.ingest.output_path
  function_name = local.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  code_sha256   = data.archive_file.ingest.output_base64sha256

  runtime       = "python3.14"
  architectures = ["x86_64"]
  memory_size   = 1024
  timeout       = 180

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
    log_group             = aws_cloudwatch_log_group.ingest_log_group.name
  }

  layers = [
    # Pandas dependency
    local.pandas_layer_arn,
    # dbfread dependency
    aws_lambda_layer_version.dbfread.arn
  ]

  environment {
    variables = {
      ENVIRONMENT = var.environment
      LOG_LEVEL   = "info"
    }
  }

  # Ensure log group exists before function
  depends_on = [aws_cloudwatch_log_group.ingest_log_group]

  tags = var.tags
}