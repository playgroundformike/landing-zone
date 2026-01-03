# AWS Organizations Module
# Creates the organization, OUs, and member accounts

#------------------------------------------------------------------------------
# AWS Organization
#------------------------------------------------------------------------------
resource "aws_organizations_organization" "org" {

  #  pre-authorizes AWS services to work across your entire organization




  aws_service_access_principals = [
    "cloudtrail.amazonaws.com", # organization wide audit trail
    "config.amazonaws.com",     # organization wide compliance rules
    "sso.amazonaws.com",        # organization wide single sign-on
    "ram.amazonaws.com",        # For Transit Gateway sharing
  ]

  feature_set = "ALL" # Shared billing & Full features: SCPs, Tag Policies, RAM sharing, delegated admin



  enabled_policy_types = [ # Enable SCP and Tag Policy
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
  ]
}

# This is a one-time enablement that tells RAM "yes, I allow sharing resources with my organization members."
resource "aws_ram_sharing_with_organization" "enable" {}

#------------------------------------------------------------------------------
# Organizational Units - OUs let you apply policies to groups of accounts 
#------------------------------------------------------------------------------
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.org.roots[0].id

  tags = {
    Purpose = "Security and compliance accounts"
  }
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.org.roots[0].id

  tags = {
    Purpose = "Shared infrastructure accounts"
  }
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.org.roots[0].id

  tags = {
    Purpose = "Application workload accounts"
  }
}

#------------------------------------------------------------------------------
# Member Accounts - provisions BRAND NEW AWS accounts
#------------------------------------------------------------------------------

# Shared Services Account
resource "aws_organizations_account" "shared_services" {

  name      = var.shared_services_account_name
  email     = var.shared_services_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  # Prevent accidental deletion of account on terraform destroy
  close_on_deletion = false

  # IAM role that can be assumed from management account
  role_name = "OrganizationAccountAccessRole"

  tags = {
    AccountType = "SharedServices"
    Purpose     = "Transit Gateway and centralized logging"
  }

  lifecycle {
    # Email cannot be changed after creation
    ignore_changes = [email]
  }
}

# Workload Account
resource "aws_organizations_account" "workload" {
  name      = var.workload_account_name
  email     = var.workload_account_email
  parent_id = aws_organizations_organizational_unit.workloads.id

  close_on_deletion = false
  role_name         = "OrganizationAccountAccessRole"

  tags = {
    AccountType = "Workload"
    Purpose     = "Application workloads"
  }

  lifecycle {
    ignore_changes = [email]
  }
}
