resource "aws_cloudwatch_log_group" "place_order_logs" {
  name              = "/aws/lambda/${local.lambda_place_order_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "create_order_logs" {
  name              = "/aws/lambda/${local.lambda_crete_order_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "reject_order_logs" {
  name              = "/aws/lambda/${local.lambda_reject_order_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "gateway_logs" {
  name              = "/aws/apigateway/${local.gateway_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "process_order_logs" {
  name              = "/aws/states/${local.state_machine_name}"
  retention_in_days = 1
}

