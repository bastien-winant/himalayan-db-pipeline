locals {
  schedule_name = "${var.name_prefix}-schedule"
}

# IAM permission for scheduler execution
data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

# IAM role for scheduler to assume
resource "aws_iam_role" "scheduler_role" {
  name_prefix          = local.schedule_name
  assume_role_policy   = data.aws_iam_policy_document.scheduler_assume_role.json
  max_session_duration = 3600
  tags                 = var.tags
}

# Policy document for scheduling the ingest function
data "aws_iam_policy_document" "scheduler_policy_document" {
  statement {
    effect    = "Allow"
    resources = [var.ingest_function_arn]
    actions   = ["lambda:InvokeFunction"]
  }
}

resource "aws_iam_role_policy" "scheduler_policy" {
  name_prefix = local.schedule_name
  role        = aws_iam_role.scheduler_role.id
  policy      = data.aws_iam_policy_document.scheduler_policy_document.json
}

resource "aws_scheduler_schedule" "schedule" {
  name = local.schedule_name
  
  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 60
  }

  target {
    arn      = var.ingest_function_arn
    role_arn = aws_iam_role.scheduler_role.arn
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_timezone
}