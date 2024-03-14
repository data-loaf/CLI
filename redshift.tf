# Random Password Suffix

resource "random_string" "unique_suffix" {
  length  = 6
  special = false
}

# Resources

# Configure az
data "aws_availability_zones" "available" {}

# Setup VPC
resource "aws_vpc" "dataloaf-redshift-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# Create Redshift subnets
resource "aws_subnet" "dataloaf-redshift-subnet-az1" {
  vpc_id            = aws_vpc.dataloaf-redshift-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "dataloaf-redshift-subnet-az2" {
  vpc_id            = aws_vpc.dataloaf-redshift-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Create subnet group
resource "aws_redshift_subnet_group" "dataloaf-redshift-subnet-group" {
  depends_on = [
    aws_subnet.dataloaf-redshift-subnet-az1,
    aws_subnet.dataloaf-redshift-subnet-az2,
  ]

  name       = "dataloaf-redshift-subnet-group"
  subnet_ids = [aws_subnet.dataloaf-redshift-subnet-az1.id, aws_subnet.dataloaf-redshift-subnet-az2.id]
}

# Create public internet gateway (0.0.0.0) is open to everyone on network
resource "aws_internet_gateway" "dataloaf-redshift-igw" {
  vpc_id = aws_vpc.dataloaf-redshift-vpc.id
}

# Create route table
resource "aws_route_table" "dataloaf-redshift-route-table" {
  vpc_id = aws_vpc.dataloaf-redshift-vpc.id

  # All outbound traffic will be routed through the igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dataloaf-redshift-igw.id
  }
}

# Assign the redshift route table to handle subnets
resource "aws_route_table_association" "dataloaf-redshift-subnet-rt-association-igw-az1" {
  subnet_id      = aws_subnet.dataloaf-redshift-subnet-az1.id
  route_table_id = aws_route_table.dataloaf-redshift-route-table.id
}

resource "aws_route_table_association" "dataloaf-redshift-subnet-rt-association-igw-az2" {
  subnet_id      = aws_subnet.dataloaf-redshift-subnet-az2.id
  route_table_id = aws_route_table.dataloaf-redshift-route-table.id
}

# Security group
resource "aws_default_security_group" "redshift_security_group" {
  depends_on = [aws_vpc.dataloaf-redshift-vpc]

  vpc_id = aws_vpc.dataloaf-redshift-vpc.id

  ingress {
    description = "Redshift Port"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM Role for Redshift
resource "aws_iam_role" "redshift_iam_role" {
  name = "dataloaf-redshift-role"

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
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_full_access"
  role = aws_iam_role.redshift_iam_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "*"
      }
    ]
    }
  )
}

// Spin up cluster
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier        = "loaf-cluster"
  database_name             = "loaf_db"
  master_username           = "loafadmin"
  master_password           = "Loafpassword1"
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.dataloaf-redshift-subnet-group.name
  vpc_security_group_ids    = ["${aws_default_security_group.redshift_security_group.id}"]
  publicly_accessible       = true
  iam_roles                 = [aws_iam_role.redshift_iam_role.arn]
  provisioner "local-exec" {
    command = "psql \"postgresql://${self.master_username}:${self.master_password}@${self.endpoint}/${self.database_name}\" -f ./redshift_table.sql"
  }
  skip_final_snapshot = true
}

resource "aws_secretsmanager_secret" "redshift_connection" {
  description = "Redshift connect details"
  name        = "redshift_secret_loaf_${random_string.unique_suffix.result}"
}

// Use secrets manager to handle connection
resource "aws_secretsmanager_secret_version" "redshift_connection" {
  secret_id = aws_secretsmanager_secret.redshift_connection.id
  secret_string = jsonencode({
    username            = aws_redshift_cluster.redshift_cluster.master_username
    password            = aws_redshift_cluster.redshift_cluster.master_password
    engine              = "redshift"
    host                = aws_redshift_cluster.redshift_cluster.endpoint
    port                = "5439"
    dbClusterIdentifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  })
}

// REDSHIFT FULL ACCESS
