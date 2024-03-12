# Random Password Suffix

resource "random_string" "unique_suffix" {
  length  = 6
  special = false
}

# Resources

resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "loaf-cluster"
  database_name      = "loaf_db"
  master_username    = "loafadmin"
  master_password    = "Loafpassword1"
  node_type          = "dc2.large"
  cluster_type       = "single-node"
  iam_roles          = [aws_iam_role.redshift_iam_role.arn]

  skip_final_snapshot = true
}

resource "aws_secretsmanager_secret" "redshift_connection" {
  description = "Redshift connect details"
  name        = "redshift_secret_${random_string.unique_suffix.result}"
}

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