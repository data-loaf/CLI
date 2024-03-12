terraform fmt
terraform apply -var-file=api_gateway_variables.tfvars -var-file=provider_variables.tfvars -auto-approve
