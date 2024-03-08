/* resource "aws_api_gateway_rest_api" "gateway_trial" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "gateway_trial"
      version = "1.0"
    }
    paths = {
      "/events" = {
        post = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
          }
        }
      }
    }
  })

  
  resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}
 

  name = "gateway_trial"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "example"
}
 */
provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_apigatewayv2_api" "gateway_trial" {
  name          = "gateway_trial4"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "events_route" {
  api_id    = aws_apigatewayv2_api.gateway_trial.id
  route_key = "POST /lambda_func"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.gateway_trial.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "Lambda example"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda_trial.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

# Example Lambda Function
resource "aws_lambda_function" "lambda_trial" {
  filename      = "lambda_func.zip"
  function_name = "lambda_func"
  role          = aws_iam_role.iam_trial.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.gateway_trial.id
  name   = "bake-stage"

  auto_deploy = true
}

# Example IAM Role for Lambda
resource "aws_iam_role" "iam_trial" {
  name = "iam_trial1"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
/*
resource "aws_iam_policy" "lambda_invoke_policy" {
  name = "lambda_invoke_rule"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = aws_lambda_function.lambda_trial.arn
      },
    ]
  })
} */

resource "aws_lambda_permission" "allow_api" {
  statement_id_prefix = "ExecuteByAPI"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.lambda_trial.function_name
  principal           = "apigateway.amazonaws.com"
  source_arn          = "${aws_apigatewayv2_api.gateway_trial.execution_arn}/*/*/lambda_func"
}
/* 
resource "aws_iam_policy_attachment" "lambda_execution_policy_attachment" {
  name       = "lambda_execution_policy_attachment"
  roles      = [aws_iam_role.iam_trial.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_invoke_policy_attachment" {
  name       = "lambda_invoke_policy_attachment"
  roles      = [aws_iam_role.iam_trial.name]
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
} */