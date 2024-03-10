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
  name                = "firehose_test_role"
  assume_role_policy  = data.aws_iam_policy_document.firehose_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.firehose_managed_policy.arn]
}