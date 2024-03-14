# Our firehose streams and attributes
locals {
  delivery_streams = {
    events = {
      name        = "events-firehose-delivery-stream"
      destination = "redshift"
      table_name  = "events"
      bucket_arn  = aws_s3_bucket.events_bucket.arn
    },
    users = {
      name        = "users-firehose-delivery-stream"
      destination = "redshift"
      table_name  = "users"
      bucket_arn  = aws_s3_bucket.users_bucket.arn
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  for_each = local.delivery_streams

  name        = each.value.name
  destination = each.value.destination

  redshift_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    cluster_jdbcurl = "jdbc:redshift://${aws_redshift_cluster.redshift_cluster.endpoint}/${aws_redshift_cluster.redshift_cluster.database_name}"
    username        = aws_redshift_cluster.redshift_cluster.master_username
    password        = aws_redshift_cluster.redshift_cluster.master_password
    data_table_name = each.value.table_name
    copy_options    = "FORMAT AS JSON 'auto' GZIP"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = each.value.bucket_arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
    }

    s3_backup_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = each.value.bucket_arn
      buffering_size     = 15
      buffering_interval = 300
      compression_format = "GZIP"
    }
  }
}

data "aws_region" "current" {}

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
        Action = [
          "s3:AbortMultipartUpload",
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
