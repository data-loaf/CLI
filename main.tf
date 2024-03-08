provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

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

# Example Lambda Function
resource "aws_lambda_function" "events_lambda" {
  filename      = "events.zip"
  function_name = "events"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.event_gateway.id
  name   = "bake-stage"

  auto_deploy = true
}

resource "aws_iam_policy" "lambda_managed_policy" {
  name = "lambda-firehose-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["firehose:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Example IAM Role for Lambda
resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_iam_role"
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
  managed_policy_arns = [aws_iam_policy.lambda_managed_policy.arn]
}

resource "aws_lambda_permission" "allow_api" {
  statement_id_prefix = "ExecuteByAPI"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.events_lambda.function_name
  principal           = "apigateway.amazonaws.com"
  source_arn          = "${aws_apigatewayv2_api.event_gateway.execution_arn}/*/*/events"
}

// Firehose
resource "aws_kinesis_firehose_delivery_stream" "events_firehose" {
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.events_bucket.arn
  }
}

data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }
}

resource "aws_iam_policy" "firehose_managed_policy" {
  name = "firehose-managed-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
        "s3:PutObject"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

}

resource "aws_iam_role" "firehose_role" {
  name                = "firehose_test_role"
  assume_role_policy  = data.aws_iam_policy_document.firehose_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.firehose_managed_policy.arn]
}

// S3
resource "aws_s3_bucket" "events_bucket" {}