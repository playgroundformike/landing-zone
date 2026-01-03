# Terragrunt configuration for Shared Services VPC
# Deployed in the Shared Services Account

include "root" {
   path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

dependency "transit_gateway" {
  config_path = "../transit-gateway"

  mock_outputs = {
    transit_gateway_id = "tgw-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Override provider to assume role into Shared Services account
generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::677466569873:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Project     = "landing-zone"
      ManagedBy   = "Terraform"
      Environment = "shared-services"
    }
  }
}
PROVIDER
}

inputs = {
  project_name       = "landing-zone"
  environment        = "shared-services"
  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  # TGW attachment - Shared Services owns the TGW, no RAM acceptance needed
  create_tgw_attachment = true
  transit_gateway_id    = dependency.transit_gateway.outputs.transit_gateway_id
  tgw_destination_cidrs = ["10.2.0.0/16"]  # Route to Workload VPC

  # NAT Gateway for private subnet internet access
  create_nat_gateway = true
}
