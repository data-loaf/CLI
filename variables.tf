# AWS connection & authentication

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  default     = ""
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

# api gateway variables
variable "api_gateway_name" {
  type        = string
  description = "api gateway name"
}

variable "api_gateway_protocol" {
  type        = string
  description = "api gateway protocol"
}

variable "api_gateway_stage_name" {
  type        = string
  description = "api gateway stage name"
}

variable "api_gateway_events_route_key" {
  type        = string
  description = "api route key"
}

variable "api_gateway_integration_type" {
  type        = string
  description = "api gateway to lambda integration type"
}

variable "api_gateway_connection_type" {
  type        = string
  description = "api gateway to lambda connection type"
}

variable "api_gateway_integration_description" {
  type = string
}

variable "api_gateway_integration_method" {
  type        = string
  description = "api gateway to lambda integration method"
}

variable "api_gateway_passthrough_behavior" {
  type        = string
  description = "api gateway to lambda passthrough behavior"
}

variable "api_gateway_users_route_key" {
  type        = string
  description = "route key for users route in api gateway"
}
