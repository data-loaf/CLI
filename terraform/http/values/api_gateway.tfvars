// API Gateway Resource Variables

// API Gateway
api_gateway_name     = "loaf_api_gateway"
api_gateway_protocol = "HTTP"

// API Gateway Route
api_gateway_events_route_key       = "POST /events"
api_gateway_users_route_key        = "POST /users"
api_gateway_users_update_route_key = "PATCH /update"

// API Gateway Integration
api_gateway_integration_type        = "AWS_PROXY"
api_gateway_connection_type         = "INTERNET"
api_gateway_integration_description = "API Gateway to Lambda Integration"
api_gateway_integration_method      = "POST"
api_gateway_passthrough_behavior    = "WHEN_NO_MATCH"

// API Stage
api_gateway_stage_name = "bake-stage"
