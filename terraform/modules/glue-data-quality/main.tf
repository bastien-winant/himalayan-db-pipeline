locals {
  job_name            = "${var.name_prefix}-stg-dq-checks"
  catalog_script_path = "${path.root}/../src/himalayan_db_pipeline/scripts/CatalogDataQuality.py"
}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_iam_role" "glue_role" {
  name_prefix          = local.job_name
  assume_role_policy   = data.aws_iam_policy_document.glue_assume_role.json
  max_session_duration = 3600
  tags                 = var.tags
}

data "aws_iam_policy_document" "glue_policy_document" {
  # S3 permissions to read raw data and script files
  statement {
    sid    = "S3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${var.data_bucket_arn}/data/*",
      "${var.artifacts_bucket_arn}/glue-scripts/*"
    ]
  }

  # CloudWatch Logs - for jobs and crawlers
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws-glue/jobs/*",
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws-glue/crawlers/*"
    ]
  }
}

resource "aws_iam_role_policy" "glue_policy" {
  name_prefix = local.job_name
  role        = aws_iam_role.glue_role.id
  policy      = data.aws_iam_policy_document.glue_policy_document.json
}

# Upload catalog data quality script to S3
resource "aws_s3_object" "catalog_glue_script" {
  bucket = var.artifacts_bucket_name
  key    = "glue-scripts/CatalogDataQuality.py"
  source = local.catalog_script_path
  etag   = filemd5(local.catalog_script_path)
  tags   = var.tags

  lifecycle {
    precondition {
      condition     = fileexists(local.catalog_script_path)
      error_message = "Catalog Glue script file does not exist at ${local.catalog_script_path}"
    }
  }
}