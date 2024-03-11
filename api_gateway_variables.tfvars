// API Gateway Resource Variables

// API Gateway
api_gateway_name     = "event_gateway"
api_gateway_protocol = "HTTP"

// API Gateway Route
api_gateway_events_route_key = "POST /events"

// API Gateway Integration
api_gateway_integration_type        = "AWS_PROXY"
api_gateway_connection_type         = "INTERNET"
api_gateway_integration_description = "API Gateway to Lambda Integration"
api_gateway_integration_method      = "POST"
api_gateway_passthrough_behavior    = "WHEN_NO_MATCH"

// API Stage
api_gateway_stage_name = "bake-stage"