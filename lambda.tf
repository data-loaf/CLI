# Example Lambda Function
resource "aws_lambda_function" "events_lambda" {
  filename      = "events.zip"
  function_name = "events"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
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