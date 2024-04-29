locals {
  routes = {
    events = {
      route_key = var.api_gateway_events_route_key
    },
    users = {
      route_key = var.api_gateway_users_route_key
    }
  }
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.api_gateway_name
  protocol_type = var.api_gateway_protocol
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = local.routes

  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = var.api_gateway_integration_type

  connection_type      = var.api_gateway_connection_type
  description          = var.api_gateway_integration_description
  integration_method   = var.api_gateway_integration_method
  integration_uri      = aws_lambda_function.stream_router_lambda.invoke_arn
  passthrough_behavior = var.api_gateway_passthrough_behavior
}

resource "aws_apigatewayv2_integration" "update_user_lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = var.api_gateway_integration_type

  connection_type      = var.api_gateway_connection_type
  description          = var.api_gateway_integration_description
  integration_method   = var.api_gateway_integration_method
  integration_uri      = aws_lambda_function.update_user_lambda.invoke_arn
  passthrough_behavior = var.api_gateway_passthrough_behavior
}

resource "aws_apigatewayv2_route" "update_users_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = var.api_gateway_users_update_route_key
  target    = "integrations/${aws_apigatewayv2_integration.update_user_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  name   = var.api_gateway_stage_name

  auto_deploy = true
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}
