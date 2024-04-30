# Data Update Lambda Function
resource "aws_lambda_function" "update_user_lambda" {

  filename      = "./lib/lambda_user_update.zip"
  function_name = "update_user"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout = 60

  environment {
    variables = {
      REDSHIFT_CONN_STRING = "postgresql://${aws_redshift_cluster.redshift_cluster.master_username}:${aws_redshift_cluster.redshift_cluster.master_password}@${aws_redshift_cluster.redshift_cluster.endpoint}/${aws_redshift_cluster.redshift_cluster.database_name}"
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"

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

# IAM Role for Lambda
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
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]
}

resource "aws_lambda_permission" "allow_api_update_users" {
  statement_id_prefix = "ExecuteByAPI"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.update_user_lambda.function_name
  principal           = "apigateway.amazonaws.com"
  source_arn          = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/PATCH/update"
}


