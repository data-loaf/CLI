locals {
  delivery_streams = {
    events = {
      name        = "events-firehose-delivery-stream"
      destination = "redshift"
      source      = "loaf-event-kinesis-stream"
      table_name  = "events"
      bucket_arn  = aws_s3_bucket.events_bucket.arn
    },
    users = {
      name        = "users-firehose-delivery-stream"
      destination = "redshift"
      source      = "loaf-user-kinesis-stream"
      table_name  = "users"
      bucket_arn  = aws_s3_bucket.users_bucket.arn
    }
  }
}

resource "aws_s3_bucket" "events_bucket" {}
resource "aws_s3_bucket" "users_bucket" {}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  for_each = local.delivery_streams
  name     = each.value.name

  tags = {
    Product = "Demo"
  }
}

resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  for_each       = local.delivery_streams
  name           = each.value.name
  log_group_name = aws_cloudwatch_log_group.firehose_log_group[each.key].name
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

resource "aws_iam_policy" "firehose_policy" {
  name = "firehose_policy"

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
          "s3:PutObject",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

}

resource "aws_iam_role" "firehose_role" {
  name                = "firehose_role"
  assume_role_policy  = data.aws_iam_policy_document.firehose_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.firehose_policy.arn]
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
      buffering_interval = 60
      compression_format = "GZIP"
    }

    s3_backup_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = each.value.bucket_arn
      buffering_size     = 15
      buffering_interval = 60
      compression_format = "GZIP"
    }

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group[each.key].name
      log_stream_name = aws_cloudwatch_log_stream.firehose_log_stream[each.key].name
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.loaf_stream[each.key].arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}
