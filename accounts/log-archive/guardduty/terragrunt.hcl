# Terragrunt configuration for GuardDuty
# Deployed in the Log Archive Account

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/guardduty"
}

dependency "organizations" {
  config_path = "../../management/organizations"

  mock_outputs = {
    log_archive_account_id = "000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

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
  log_archive_account_id = dependency.organizations.outputs.log_archive_account_id
}

