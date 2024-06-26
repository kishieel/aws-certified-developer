resource "aws_lambda_function" "lambda" {
  function_name    = "ProcessStream"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda.handler"
  filename         = data.archive_file.source.output_path
  source_code_hash = data.archive_file.source.output_base64sha256
  runtime          = "nodejs18.x"
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  function_name     = aws_lambda_function.lambda.function_name
  event_source_arn  = aws_dynamodb_table.local_table.stream_arn
  starting_position = "LATEST"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 1
}
