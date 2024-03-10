resource "aws_apigatewayv2_api" "event_gateway" {
  name          = "event_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "events_route" {
  api_id    = aws_apigatewayv2_api.event_gateway.id
  route_key = "POST /events"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.event_gateway.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda example"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.events_lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.event_gateway.id
  name   = "bake-stage"

  auto_deploy = true
}