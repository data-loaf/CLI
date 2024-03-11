resource "aws_apigatewayv2_api" "event_gateway" {
  name          = var.api_gateway_name
  protocol_type = var.api_gateway_protocol
}

resource "aws_apigatewayv2_route" "events_route" {
  api_id    = aws_apigatewayv2_api.event_gateway.id
  route_key = var.api_gateway_events_route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.event_gateway.id
  integration_type = var.api_gateway_integration_type

  connection_type      = var.api_gateway_connection_type
  description          = var.api_gateway_integration_description
  integration_method   = var.api_gateway_integration_method
  integration_uri      = aws_lambda_function.events_lambda.invoke_arn
  passthrough_behavior = var.api_gateway_passthrough_behavior
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.event_gateway.id
  name   = var.api_gateway_stage_name

  auto_deploy = true
}