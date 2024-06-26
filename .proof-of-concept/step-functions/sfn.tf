resource "aws_sfn_state_machine" "process_order" {
  name       = local.state_machine_name
  role_arn   = aws_iam_role.sfn_role.arn
  type       = "EXPRESS"
  definition = jsonencode({
    Comment = "Process Order Workflow"
    StartAt = "PlaceOrder"
    States  = {
      PlaceOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.place_order.arn
        Next     = "ValidateBalance"
      }
      ValidateBalance = {
        Type    = "Choice"
        Choices = [
          {
            Variable      = "$.enoughCoins"
            BooleanEquals = true
            Next          = "CreateOrder"
          }
        ]
        Default = "RejectOrder"
      }
      CreateOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.create_order.arn
        End      = true
      }
      RejectOrder = {
        Type     = "Task"
        Resource = aws_lambda_function.reject_order.arn
        End      = true
      }
    }
  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.process_order_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}

