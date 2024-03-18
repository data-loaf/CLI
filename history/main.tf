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
  name        = "events-firehose-delivery-stream"
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
  name                = "dataloaf-firehose_role"
  assume_role_policy  = data.aws_iam_policy_document.firehose_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.firehose_managed_policy.arn]
}

// S3
resource "aws_s3_bucket" "events_bucket" {}

//Redshift

# Create an IAM Role for Redshift
resource "aws_iam_role" "redshift-serverless-role" {
  name = "dataloaf-redshift-serverless-assumerole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "redshift.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })


  tags = {
    Name        = "dataloaf-redshift-serverless-assumerole"
    Environment = "prod"
  }
}

# Create the Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "serverless_namespace" {
  namespace_name      = "dataloaf_redshift_namespace" // get customer input for db_name, admin_username, admin_user_password from CLI or something else
  db_name             = "loaf_db"
  admin_username      = "loafadmin"
  admin_user_password = "loafpassword"
  iam_roles           = [aws_iam_role.redshift-serverless-role.arn]

  tags = {
    Name        = "dataloaf_redshift_namespace"
    Environment = "prod"
  }
}

# Create the Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "serverless_workgroup" {
  depends_on = [aws_redshiftserverless_namespace.serverless_namespace]

  namespace_name = aws_redshiftserverless_namespace.serverless_namespace.id
  workgroup_name = "dataloaf_redshift_workgroup"
  base_capacity  = 8

  security_group_ids = [aws_security_group.redshift-serverless-security-group.id]
  subnet_ids = [
    aws_subnet.redshift-serverless-subnet-az1.id,
    aws_subnet.redshift-serverless-subnet-az2.id,
    aws_subnet.redshift-serverless-subnet-az3.id,
    aws_subnet.redshift-serverless-subnet-az4.id,
    aws_subnet.redshift-serverless-subnet-az5.id,
    aws_subnet.redshift-serverless-subnet-az6.id,
  ]
  publicly_accessible = true
}

# Redshift VPC
# AWS Availability Zones data
data "aws_availability_zones" "available" {}

# Create the VPC
resource "aws_vpc" "redshift-serverless-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create the Redshift Subnet AZ1
resource "aws_subnet" "redshift-serverless-subnet-az1" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.0.1/16"
  availability_zone = data.aws_availability_zones.available.names[0]
}

# Create the Redshift Subnet AZ2
resource "aws_subnet" "redshift-serverless-subnet-az2" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.0.2/16"
  availability_zone = data.aws_availability_zones.available.names[1]

}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az3" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.0.3/16"
  availability_zone = data.aws_availability_zones.available.names[2]
}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az4" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.0.4/16"
  availability_zone = data.aws_availability_zones.available.names[3]
}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az5" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.0.5/16"
  availability_zone = data.aws_availability_zones.available.names[4]

}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az6" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.0.6/16"
  availability_zone = data.aws_availability_zones.available.names[5]
}

//Redshift Security Group
# Create a Security Group for Redshift Serverless
resource "aws_security_group" "redshift-serverless-security-group" {
  depends_on = [aws_vpc.redshift-serverless-vpc]

  name        = "dataloaf-redshift-serverless-security-group"
  description = "description- dataloaf-redshift-serverless-security-group"

  vpc_id = aws_vpc.redshift-serverless-vpc.id

  ingress {
    description = "Redshift port"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["52.70.63.192/27"] // update this to secure the connection to the cluster
  }
}
