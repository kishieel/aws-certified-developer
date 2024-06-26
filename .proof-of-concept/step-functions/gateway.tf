// @info:
// I am considering whether REST API wouldn't be better in this case as
// with current implementation the whole response from state machine is exposed
// to the client and the particular output from the last step is returned as string
// rather than JSON. Also account number and some other details are exposed.

resource "aws_apigatewayv2_api" "gateway" {
  name          = local.gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "v1" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "v1"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.gateway_logs.arn
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

resource "aws_apigatewayv2_integration" "place_order" {
  api_id              = aws_apigatewayv2_api.gateway.id
  credentials_arn     = aws_iam_role.gateway_role.arn
  integration_type    = "AWS_PROXY"
  integration_subtype = "StepFunctions-StartSyncExecution"

  request_parameters = {
    StateMachineArn = aws_sfn_state_machine.process_order.arn
    Input = "$request.body"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_route" "place_order" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "POST /place-order"
  target    = "integrations/${aws_apigatewayv2_integration.place_order.id}"
}

