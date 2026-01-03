# Terragrunt configuration for Service Control Policies
# Deployed in the Management Account

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/scp"
}

# Pull outputs from the Organizations deployment
dependency "organizations" {
  config_path = "../organizations"
  
  # Mock outputs for plan when organizations hasn't been applied yet
  mock_outputs = {
    ou_workloads_id      = "ou-mock-workloads"
    ou_infrastructure_id = "ou-mock-infrastructure"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  # OU IDs from Phase 1
  workloads_ou_id      = dependency.organizations.outputs.ou_workloads_id
  infrastructure_ou_id = dependency.organizations.outputs.ou_infrastructure_id
  
  # Regions where workload accounts can create resources
  # Add more regions as needed for your use case
  allowed_regions = ["us-east-1", "us-east-2"]
  
  # Roles that are allowed to modify security controls
  # OrganizationAccountAccessRole is the default admin role created by Organizations
  security_admin_role_patterns = [
    "arn:aws:iam::*:role/OrganizationAccountAccessRole",
    "arn:aws:iam::*:role/Admin*"
  ]
}
