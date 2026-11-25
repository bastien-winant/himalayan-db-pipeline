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