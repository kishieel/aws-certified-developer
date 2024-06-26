data "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/lambda.js"
  output_path = "${path.module}/out.zip"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "AWSLambdaProcessStream"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_logs.arn}:*"]
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_stream" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
    ]
    resources = [
      aws_dynamodb_table.local_table.arn,
      "${aws_dynamodb_table.local_table.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_cloudwatch_logs.json
}

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_dynamodb_stream.json
}
