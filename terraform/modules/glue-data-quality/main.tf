locals {
  script_path = "${path.root}/../src/himalayan_db_pipeline/scripts/GlueDataQualityDynamicRules.py"
}

resource "aws_cloudwatch_log_group" "glue_log_group" {
  name              = "/aws-glue/jobs/${var.glue_job_name}"
  retention_in_days = var.cloudwatch_retention_days
  tags              = var.tags
}

resource "aws_s3_object" "glue_script" {
  bucket = var.artifacts_bucket_name
  key    = "glue-scripts/GlueDataQualityDynamicRules.py"
  source = local.script_path
  etag   = filemd5(local.script_path)
  tags   = var.tags

  lifecycle {
    precondition {
      condition     = fileexists(local.script_path)
      error_message = "Glue script file does not exist at ${local.script_path}"
    }
  }
}