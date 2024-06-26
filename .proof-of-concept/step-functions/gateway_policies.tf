data "aws_iam_policy_document" "gateway_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "gateway_cloudwatch_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"] // @fixme
  }
}

data "aws_iam_policy_document" "gateway_sfn_policy" {
  statement {
    effect    = "Allow"
    actions   = ["states:*"] // @fixme
    resources = ["*"] // @fixme
  }
}

resource "aws_iam_role" "gateway_role" {
  name = "AWSApiGateway"
  assume_role_policy = data.aws_iam_policy_document.gateway_assume_role.json
}

resource "aws_iam_role_policy" "gateway_cloudwatch" {
  role   = aws_iam_role.gateway_role.id
  policy = data.aws_iam_policy_document.gateway_cloudwatch_policy.json
}

resource "aws_iam_role_policy" "gateway_sfn" {
  role   = aws_iam_role.gateway_role.id
  policy = data.aws_iam_policy_document.gateway_sfn_policy.json
}
