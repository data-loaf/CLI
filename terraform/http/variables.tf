# AWS connection & authentication

variable "access_key" {
  type        = string
  description = "AWS access key"
  default     = ""
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "AWS secret key"
  default     = ""
  sensitive   = true
}

variable "region" {
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
  description = "api route key for event streaming"
}

variable "api_gateway_users_update_route_key" {
  type        = string
  description = "api route key for user updates"
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
  description = "api gateway to router lambda integration method"
}

variable "api_gateway_passthrough_behavior" {
  type        = string
  description = "api gateway to lambda passthrough behavior"
}

variable "api_gateway_users_route_key" {
  type        = string
  description = "route key for users route in api gateway"
}

// Redshift variables

variable "redshift_db_name" {
  type        = string
  description = "Redshift Database Name"
  sensitive   = true
}

variable "redshift_username" {
  type        = string
  description = "Redshift Username"
  sensitive   = true
}

variable "redshift_password" {
  type        = string
  description = "Redshift Password"
  sensitive   = true
}

# Customer Fullstack Domain

variable "domain_name" {
  type        = string
  description = "Domain name for the full stack application"
}

#  EC2 AMI

variable "ami" {
  type        = string
  description = "AMI for EC2 Instance"
}
