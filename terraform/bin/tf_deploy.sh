#!/bin/bash

# Get the directory path of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$ROOT_DIR"

# Check and set AWS credentials if not already set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  if [ -n "$1" ]; then
    export AWS_ACCESS_KEY_ID="$1"
  fi
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  if [ -n "$2" ]; then
    export AWS_SECRET_ACCESS_KEY="$2"
  fi
fi

# Run terraform fmt to format Terraform configuration files
echo "Formatting Terraform files..."
terraform fmt -recursive "$ROOT_DIR"

# Run terraform validate to check Terraform configuration files
echo "Validating Terraform files..."
terraform validate "$ROOT_DIR"

# Run terraform apply to provision resources from Terraform configuration files
echo "Provisioning Terraform resources..."
terraform apply -var-file="values/api_gateway.tfvars" \
                -var-file="values/provider.tfvars" \
                -var-file="values/redshift.tfvars" \
                -auto-approve
