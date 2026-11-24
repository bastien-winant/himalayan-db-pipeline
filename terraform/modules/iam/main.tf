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
  name_prefix = var.name_prefix
  assume_role_policy   = data.aws_iam_policy_document.glue_assume_role.json
  max_session_duration = 3600
  
  tags = var.tags
}

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

resource "aws_iam_role" "lambda_role" {
  name_prefix = var.name_prefix
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600
  tags = var.tags
}