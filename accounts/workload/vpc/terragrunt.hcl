# Terragrunt configuration for Workload VPC
# Deployed in the Workload Account

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/vpc"
}

dependency "transit_gateway" {
  config_path = "../../shared-services/transit-gateway"

  mock_outputs = {
    transit_gateway_id     = "tgw-mock"
    ram_resource_share_arn = "arn:aws:ram:us-east-1:000000000000:resource-share/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Override provider to assume role into Workload account
generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::997868087642:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Project     = "landing-zone"
      ManagedBy   = "Terraform"
      Environment = "workload"
    }
  }
}
PROVIDER
}

inputs = {
  project_name       = "landing-zone"
  environment        = "workload"
  vpc_cidr           = "10.2.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  # TGW attachment
  create_tgw_attachment  = true
  transit_gateway_id     = dependency.transit_gateway.outputs.transit_gateway_id
  tgw_destination_cidrs  = ["10.1.0.0/16"]  # Route to Shared Services VPC

  # Accept RAM share from Shared Services
  accept_ram_share       = true
  ram_resource_share_arn = dependency.transit_gateway.outputs.ram_resource_share_arn

  # No NAT - use centralized egress through Shared Services if needed
  create_nat_gateway = false
}
