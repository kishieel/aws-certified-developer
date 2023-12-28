data "aws_iam_policy_document" "fn-image-resize-assume-role-policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "fn-image-resize-s3-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
    ]
    resources = ["${var.bucket_arn}/*"]
  }
}

data "aws_iam_policy_document" "fn-image-resize-logs-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.fn-image-resize-logs.arn}:*"]
  }
}

data "aws_iam_policy_document" "fn-image-resize-sqs-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [var.queue_arn]
  }
}

resource "aws_iam_role" "fn-image-resize-role" {
  name               = "AWSLambdaImageResize"
  assume_role_policy = data.aws_iam_policy_document.fn-image-resize-assume-role-policy.json
}

resource "aws_iam_role_policy" "fn-image-resize-s3-policy" {
  role   = aws_iam_role.fn-image-resize-role.id
  policy = data.aws_iam_policy_document.fn-image-resize-s3-policy.json
}

resource "aws_iam_role_policy" "fn-image-resize-logs-policy" {
  role   = aws_iam_role.fn-image-resize-role.id
  policy = data.aws_iam_policy_document.fn-image-resize-logs-policy.json
}

resource "aws_iam_role_policy" "fn-image-resize-sqs-policy" {
  role   = aws_iam_role.fn-image-resize-role.id
  policy = data.aws_iam_policy_document.fn-image-resize-sqs-policy.json
}

data "archive_file" "lab4-image-resize-zip" {
  type        = "zip"
  source_file = "${path.module}/main.js"
  output_path = "${path.module}/out.zip"
}

resource "aws_lambda_function" "fn-image-resize" {
  function_name    = "ImageResize"
  role             = aws_iam_role.fn-image-resize-role.arn
  handler          = "main.handler"
  filename         = data.archive_file.lab4-image-resize-zip.output_path
  source_code_hash = data.archive_file.lab4-image-resize-zip.output_base64sha256
  runtime          = "nodejs18.x"
  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}

resource "aws_cloudwatch_log_group" "fn-image-resize-logs" {
  name              = "/aws/lambda/${aws_lambda_function.fn-image-resize.function_name}"
  retention_in_days = 1
}

resource "aws_lambda_permission" "allow_bucket" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn-image-resize.function_name
  source_arn    = var.bucket_arn
  principal     = "s3.amazonaws.com"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  enabled          = true
  function_name    = aws_lambda_function.fn-image-resize.function_name
  event_source_arn = var.queue_arn
  batch_size       = 1
}
