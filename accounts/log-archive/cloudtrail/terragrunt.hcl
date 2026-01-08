# Terragrunt Deployment for Log Archive 
# Deployed in the Log Archive account


include "root" {

  # inherits provider
  # remote state
  # inputs

  path = find_in_parent_folders("root.hcl")

}

# Points to the Terraform module to deploy. The relative path navigates from the current directory to the module:
terraform {
  source = "../../../modules/log-archive"
}

dependency "organizations" {
  config_path = "../../management/organizations"
  
  mock_outputs = {
    log_archive_account_id   = "000000000000"
    organization_id          = "o-mock"
    management_account_id    = "000000000001"
    shared_services_account_id = "000000000002"
    workload_account_id      = "000000000003"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Override provider to assume role into Log Archive account
generate "provider_override" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${dependency.organizations.outputs.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Project     = "Landing-Zone"
      ManagedBy   = "Terraform"
      Environment = "Log-Archive"
    }
  }
}
PROVIDER
}



inputs = {
  # project_name and aws_region inherited from root.hcl

  log_archive_account_id   = dependency.organizations.outputs.log_archive_account_id
  organization_id          = dependency.organizations.outputs.organization_id
  organization_account_ids = [
    dependency.organizations.outputs.management_account_id,
    dependency.organizations.outputs.shared_services_account_id,
    dependency.organizations.outputs.workload_account_id,
    dependency.organizations.outputs.log_archive_account_id,
  ]
}