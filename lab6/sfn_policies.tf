data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sfn_allow_lambda_actions" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:*",]
    resources = ["*"] // @fixme
  }
}

data "aws_iam_policy_document" "sfn_allow_cloudwatch_actions" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogStream",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "sfn_role" {
  name               = "AWSStateMachine"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json
}

resource "aws_iam_role_policy" "sfn_allow_lambda_actions" {
  role   = aws_iam_role.sfn_role.id
  policy = data.aws_iam_policy_document.sfn_allow_lambda_actions.json
}

resource "aws_iam_role_policy" "sfn_allow_cloudwatch_actions" {
  role   = aws_iam_role.sfn_role.id
  policy = data.aws_iam_policy_document.sfn_allow_cloudwatch_actions.json
}
