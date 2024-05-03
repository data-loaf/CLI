resource "aws_lambda_function" "update_user_lambda" {
  filename      = "./lib/lambda_user_update.zip"
  function_name = "update_user"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 60

  environment {
    variables = {
      REDSHIFT_CONN_STRING = "postgresql://${aws_redshift_cluster.redshift_cluster.master_username}:${aws_redshift_cluster.redshift_cluster.master_password}@${aws_redshift_cluster.redshift_cluster.endpoint}/${aws_redshift_cluster.redshift_cluster.database_name}"
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_iam_role" {
  name               = "lambda_iam_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn          = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/POST/update_users"
}

