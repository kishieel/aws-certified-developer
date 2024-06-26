data "aws_iam_policy_document" "fn-image-upload-assume-role-policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "fn-image-upload-s3-policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.bucket_arn}/*"]
  }
}

data "aws_iam_policy_document" "fn-image-upload-logs-policy" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.fn-image-upload-logs.arn}:*"]
  }
}

resource "aws_iam_role" "fn-image-upload-role" {
  name               = "AWSLambdaImageUpload"
  assume_role_policy = data.aws_iam_policy_document.fn-image-upload-assume-role-policy.json
}

resource "aws_iam_role_policy" "fn-image-upload-s3-policy" {
  role   = aws_iam_role.fn-image-upload-role.id
  policy = data.aws_iam_policy_document.fn-image-upload-s3-policy.json
}

resource "aws_iam_role_policy" "fn-image-upload-logs-policy" {
  role   = aws_iam_role.fn-image-upload-role.id
  policy = data.aws_iam_policy_document.fn-image-upload-logs-policy.json
}

data "archive_file" "lab4-image-upload-zip" {
  type        = "zip"
  source_file = "${path.module}/main.js"
  output_path = "${path.module}/out.zip"
}

resource "aws_lambda_function" "fn-image-upload" {
  function_name    = "ImageUpload"
  role             = aws_iam_role.fn-image-upload-role.arn
  handler          = "main.handler"
  filename         = data.archive_file.lab4-image-upload-zip.output_path
  source_code_hash = data.archive_file.lab4-image-upload-zip.output_base64sha256
  runtime          = "nodejs18.x"
  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}

resource "aws_cloudwatch_log_group" "fn-image-upload-logs" {
  name              = "/aws/lambda/${aws_lambda_function.fn-image-upload.function_name}"
  retention_in_days = 1
}

resource "aws_apigatewayv2_api" "fn-image-upload-api" {
  name          = "ImageUploadGateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "fn-image-upload-stage" {
  api_id      = aws_apigatewayv2_api.fn-image-upload-api.id
  name        = "lab4-g4hz"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.fn-image-upload-api-logs.arn
    format          = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "fn-image-upload-integration" {
  api_id             = aws_apigatewayv2_api.fn-image-upload-api.id
  integration_uri    = aws_lambda_function.fn-image-upload.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "fn-image-upload-route" {
  api_id    = aws_apigatewayv2_api.fn-image-upload-api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.fn-image-upload-integration.id}"
}

resource "aws_cloudwatch_log_group" "fn-image-upload-api-logs" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.fn-image-upload-api.name}"
  retention_in_days = 1
}

resource "aws_lambda_permission" "fn-image-upload-gw-permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fn-image-upload.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.fn-image-upload-api.execution_arn}/*/*"
}
