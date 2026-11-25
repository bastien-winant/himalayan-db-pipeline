data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "s3_bucket" {
  source      = "./modules/s3-buckets"
  aws_region  = var.aws_region
  environment = var.environment
  account_id  = local.account_id
  name_prefix = var.name_prefix
  tags        = var.tags
}

module "lambda" {
  source                    = "./modules/lambda"
  aws_region                = var.aws_region
  environment               = var.environment
  account_id                = local.account_id
  name_prefix               = var.name_prefix
  tags                      = var.tags
  cloudwatch_retention_days = var.cloudwatch_retention_days
  data_bucket_arn           = module.s3_bucket.data_bucket_arn
}

module "schedule" {
  source              = "./modules/eventbridge-schedule"
  aws_region          = var.aws_region
  environment         = var.environment
  account_id          = local.account_id
  name_prefix         = var.name_prefix
  tags                = var.tags
  ingest_function_arn = module.lambda.ingest_function_arn
  schedule_expression = var.schedule_expression
  schedule_timezone   = var.schedule_timezone
}

resource "aws_cloudwatch_metric_alarm" "data_quality_failure" {
  alarm_name          = "${var.name_prefix}-glue-data-quality-failure"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "glue.driver.aggregate.numFailedTasks"
  namespace           = "Glue"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors glue data quality job failures"

  dimensions = {
    JobName = var.glue_job_name
  }
}