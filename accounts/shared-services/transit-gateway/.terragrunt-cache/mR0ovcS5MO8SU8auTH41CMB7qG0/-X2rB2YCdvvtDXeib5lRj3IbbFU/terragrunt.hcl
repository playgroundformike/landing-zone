# Terragrunt configuration for Transit Gateway
# Deployed in the Shared Services Account

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/transit-gateway"
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
  project_name           = "landing-zone"
  share_with_account_ids = ["997868087642"]  # Workload account
}
