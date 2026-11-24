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
  name_prefix = "${var.name_prefix}-glue"
  assume_role_policy   = data.aws_iam_policy_document.glue_assume_role.json
  max_session_duration = 3600
  
  tags = var.tags
}

data "aws_iam_policy_document" "glue_policy_document" {}

resource "aws_iam_policy" "glue_policy" {
  name_prefix = "${var.name_prefix}-glue"
  policy = data.aws_iam_policy_document.glue_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_policy_document_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
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
  name_prefix = "${var.name_prefix}-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600
  tags = var.tags
}

data "aws_iam_policy_document" "lambda_policy_document" {}

resource "aws_iam_policy" "lambda_policy" {
  name_prefix = "${var.name_prefix}-lambda"
  policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_document_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}