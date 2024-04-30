resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_gateway_name
  description = "API gateway for dataloaf"
}

resource "aws_api_gateway_resource" "events" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "update_users" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "users" // Adjust the path_part according to your API path
}

resource "aws_api_gateway_method" "post_events" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id  = aws_api_gateway_resource.events.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_users" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id  = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "patch_users" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id  = aws_api_gateway_resource.update_users.id
  http_method   = "PATCH"
  authorization = "NONE"
}

resource "aws_iam_role" "api_gateway_role" {
  name               = "api_gateway_kinesis_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })

  // Add policies for accessing Kinesis here if not already added
}

resource "aws_api_gateway_integration" "events_kinesis_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id            = aws_api_gateway_resource.events.id
  http_method             = aws_api_gateway_method.post_events.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:kinesis:action/PutRecord"
  credentials             = aws_iam_role.api_gateway_role.arn
}

resource "aws_api_gateway_integration" "users_kinesis_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id            = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.post_users.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:kinesis:action/PutRecord"
  credentials             = aws_iam_role.api_gateway_role.arn
}

resource "aws_api_gateway_integration" "update_user_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id            = aws_api_gateway_resource.update_users.id
  http_method             = aws_api_gateway_method.patch_users.http_method
  integration_http_method = "PATCH"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_user_lambda.invoke_arn
}

# Integration responses for events Kinesis integration
resource "aws_api_gateway_integration_response" "events_kinesis_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.post_events.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }
}

# Method responses for events endpoint
resource "aws_api_gateway_method_response" "events_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.post_events.http_method
  status_code = "200"
}

# Integration responses for users Kinesis integration
resource "aws_api_gateway_integration_response" "users_kinesis_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.post_users.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }
}

# Method responses for users endpoint
resource "aws_api_gateway_method_response" "users_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.users.id
  http_method = aws_api_gateway_method.post_users.http_method
  status_code = "200"
}
