resource "aws_lambda_function" "place_order" {
  function_name    = local.lambda_place_order_name
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.place_order.output_path
  source_code_hash = data.archive_file.place_order.output_base64sha256
  handler          = "main.handler"
  runtime          = "nodejs18.x"
}

resource "aws_lambda_function" "create_order" {
  function_name    = local.lambda_crete_order_name
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.create_order.output_path
  source_code_hash = data.archive_file.create_order.output_base64sha256
  handler          = "main.handler"
  runtime          = "nodejs18.x"
}

resource "aws_lambda_function" "reject_order" {
  function_name    = local.lambda_reject_order_name
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.reject_order.output_path
  source_code_hash = data.archive_file.reject_order.output_base64sha256
  handler          = "main.handler"
  runtime          = "nodejs18.x"
}
