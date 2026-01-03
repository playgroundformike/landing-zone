# Terragrunt configuration for Organizations
# Deployed in the Management Account


include "root" {

  # inherits provider
  # remote state
  # inputs

  path = find_in_parent_folders("root.hcl")

}

# Points to the Terraform module to deploy. The relative path navigates from the current directory to the module:
terraform {
  source = "../../../modules/organizations"
}

inputs = {

  shared_services_account_name  = "Shared-Services"
  shared_services_account_email = "aws.michael.aduayi+sharedservices@gmail.com"

  workload_account_name  = "Workload-Dev"
  workload_account_email = "aws.michael.aduayi+workload@gmail.com"
  
  log_archive_account_name  = "Logging"
  log_archive_account_email = "aws.michael.aduayi+logging@gmail.com"

}
