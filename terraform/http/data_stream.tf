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
