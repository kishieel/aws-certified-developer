data "aws_iam_policy_document" "fn-image-resize-dispatch-assume-role-policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "fn-image-resize-dispatch-sqs-policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [var.queue_arn]
  }
}

data "aws_iam_policy_document" "fn-image-resize-dispatch-logs-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.fn-image-resize-dispatch-logs.arn}:*"]
  }
}

resource "aws_iam_role" "fn-image-resize-dispatch-role" {
  name               = "AWSLambdaImageResizeDispatch"
  assume_role_policy = data.aws_iam_policy_document.fn-image-resize-dispatch-assume-role-policy.json
}

resource "aws_iam_role_policy" "fn-image-resize-dispatch-s3-policy" {
  role   = aws_iam_role.fn-image-resize-dispatch-role.id
  policy = data.aws_iam_policy_document.fn-image-resize-dispatch-sqs-policy.json
}

resource "aws_iam_role_policy" "fn-image-resize-dispatch-logs-policy" {
  role   = aws_iam_role.fn-image-resize-dispatch-role.id
  policy = data.aws_iam_policy_document.fn-image-resize-dispatch-logs-policy.json
}

data "archive_file" "lab4-image-resize-dispatch-zip" {
  type        = "zip"
  source_file = "${path.module}/main.js"
  output_path = "${path.module}/out.zip"
}

resource "aws_lambda_function" "fn-image-resize-dispatch" {
  function_name    = "ImageResizeDispatch"
  role             = aws_iam_role.fn-image-resize-dispatch-role.arn
  handler          = "main.handler"
  filename         = data.archive_file.lab4-image-resize-dispatch-zip.output_path
  source_code_hash = data.archive_file.lab4-image-resize-dispatch-zip.output_base64sha256
  runtime          = "nodejs18.x"
  environment {
    variables = {
      BUCKET_NAME     = var.bucket_name
      QUEUE_URL       = var.queue_url
      THUMBNAIL_SIZES = jsonencode(var.thumbnail_sizes)
    }
  }
}

resource "aws_cloudwatch_log_group" "fn-image-resize-dispatch-logs" {
  name              = "/aws/lambda/${aws_lambda_function.fn-image-resize-dispatch.function_name}"
  retention_in_days = 1
}

resource "aws_lambda_permission" "allow_bucket" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn-image-resize-dispatch.function_name
  source_arn    = var.bucket_arn
  principal     = "s3.amazonaws.com"
}

resource "aws_s3_bucket_notification" "fn-image-resize-dispatch-trigger" {
  bucket = var.bucket_id
  lambda_function {
    lambda_function_arn = aws_lambda_function.fn-image-resize-dispatch.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "images/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
