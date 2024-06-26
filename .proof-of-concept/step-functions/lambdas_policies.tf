data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_allow_cloudwatch_actions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.place_order_logs.arn}:*",
      "${aws_cloudwatch_log_group.create_order_logs.arn}:*",
      "${aws_cloudwatch_log_group.reject_order_logs.arn}:*",
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "AWSLambdas"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda_allow_cloudwatch_actions" {
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_allow_cloudwatch_actions.json
}
