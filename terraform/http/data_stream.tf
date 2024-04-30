locals {
  data_streams = {
    events = {
      name             = "loaf-event-kinesis-stream"
      retention_period = 24
      tags = {
        environment: "prod"
        stream_type: "events"
      }
    },
    users = {
      name             = "loaf-user-kinesis-stream"
      retention_period = 24
      tags = {
        environment: "prod"
        stream_type: "users"
      }
    }
  }
}

resource "aws_iam_policy" "kinesis_policy" {
  name        = "kinesis_put_record_policy"
  description = "Policy to allow PutRecord action on the Kinesis streams"
  
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "kinesis:PutRecord"
      Resource = [
        "arn:aws:kinesis:us-east-1:240398672806:stream/loaf-user-kinesis-stream",
        "arn:aws:kinesis:us-east-1:240398672806:stream/loaf-event-kinesis-stream"
      ]
    }]
  })
}

resource "aws_iam_policy_attachment" "api_gateway_kinesis_attachment" {
  name       = "api_gateway_kinesis_attachment"
  roles      = [aws_iam_role.api_gateway_role.name]
  policy_arn = aws_iam_policy.kinesis_policy.arn
}

resource "aws_kinesis_stream" "loaf_stream" {
  for_each         = local.data_streams
  name             = each.value.name
  retention_period = each.value.retention_period

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = each.value.tags
}
