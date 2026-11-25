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

# Policy document for calling the ingest function
data "aws_iam_policy_document" "scheduler_policy_document" {}

resource "aws_iam_role_policy" "scheduler_policy" {
  name_prefix = local.schedule_name
  role        = aws_iam_role.scheduler_role.id
  policy      = data.aws_iam_policy_document.scheduler_policy_document.json
}