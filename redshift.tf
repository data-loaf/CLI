//Redshift

resource "aws_iam_policy" "redshift_managed_policy" {
  name = "redshift-managed-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["redshift:*",
          "redshift-serverless:*",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeInternetGateways",
          "sns:CreateTopic",
          "sns:Get*",
          "sns:List*",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:EnableAlarmActions",
          "cloudwatch:DisableAlarmActions",
          "tag:GetResources",
          "tag:UntagResources",
          "tag:GetTagValues",
          "tag:GetTagKeys",
        "tag:TagResources"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

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

  managed_policy_arns = [aws_iam_policy.redshift_managed_policy.arn]

  tags = {
    Name        = "dataloaf-redshift-serverless-assumerole"
    Environment = "prod"
  }
}

# Create the Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "serverless_workgroup" {
  depends_on = [aws_redshiftserverless_namespace.serverless_namespace]

  namespace_name = aws_redshiftserverless_namespace.serverless_namespace.id
  workgroup_name = "dataloaf-redshift-workgroup"
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

  timeouts {
    create = "60m"
  }
}

# Create the Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "serverless_namespace" {
  namespace_name      = "dataloaf-redshift-namespace" // get customer input for db_name, admin_username, admin_user_password from CLI or something else
  db_name             = "loaf-db"
  admin_username      = "loafadmin"
  admin_user_password = "Loafpassword1"
  iam_roles           = [aws_iam_role.redshift-serverless-role.arn]

  tags = {
    Name        = "dataloaf_redshift_namespace"
    Environment = "prod"
  }
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
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

# Create the Redshift Subnet AZ2
resource "aws_subnet" "redshift-serverless-subnet-az2" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az3" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az4" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[3]
}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az5" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = data.aws_availability_zones.available.names[4]

}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az6" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = "10.0.6.0/24"
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