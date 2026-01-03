# Outputs for Organizations Module
# These values are used by other modules for cross-account configuration

#------------------------------------------------------------------------------
# Organization
#------------------------------------------------------------------------------
output "organization_id" {
  description = "The ID of the organization"
  value       = aws_organizations_organization.org.id
}

output "organization_arn" {
  description = "The ARN of the organization"
  value       = aws_organizations_organization.org.arn
}

output "organization_root_id" {
  description = "The ID of the organization root"
  value       = aws_organizations_organization.org.roots[0].id
}

output "management_account_id" {
  description = "The ID of the management account"
  value       = aws_organizations_organization.org.master_account_id
}

#------------------------------------------------------------------------------
# Organizational Units
#------------------------------------------------------------------------------
output "ou_security_id" {
  description = "The ID of the Security OU"
  value       = aws_organizations_organizational_unit.security.id
}

output "ou_infrastructure_id" {
  description = "The ID of the Infrastructure OU"
  value       = aws_organizations_organizational_unit.infrastructure.id
}

output "ou_workloads_id" {
  description = "The ID of the Workloads OU"
  value       = aws_organizations_organizational_unit.workloads.id
}

#------------------------------------------------------------------------------
# Member Accounts
#------------------------------------------------------------------------------
output "shared_services_account_id" {
  description = "The ID of the Shared Services account"
  value       = aws_organizations_account.shared_services.id
}

output "shared_services_account_arn" {
  description = "The ARN of the Shared Services account"
  value       = aws_organizations_account.shared_services.arn
}

output "workload_account_id" {
  description = "The ID of the Workload account"
  value       = aws_organizations_account.workload.id
}

output "workload_account_arn" {
  description = "The ARN of the Workload account"
  value       = aws_organizations_account.workload.arn
}

output "log_archive_account_id" {
  description = "The ID of the Logging account"
  value       = aws_organizations_account.log_archive.id
}

output "log_archive_account_arn" {
  description = "The ARN of the Logging account"
  value       = aws_organizations_account.log_archive.arn
}
#------------------------------------------------------------------------------
# Cross-Account Role ARNs (for assuming into member accounts)
#------------------------------------------------------------------------------
output "shared_services_assume_role_arn" {
  description = "ARN of the role to assume into Shared Services account"
  value       = "arn:aws:iam::${aws_organizations_account.shared_services.id}:role/OrganizationAccountAccessRole"
}

output "workload_assume_role_arn" {
  description = "ARN of the role to assume into Workload account"
  value       = "arn:aws:iam::${aws_organizations_account.workload.id}:role/OrganizationAccountAccessRole"
}

output "log_archive_assume_role_arn" {
  description = "ARN of the role to assume into Logging account"
  value       = "arn:aws:iam::${aws_organizations_account.log_archive.id}:role/OrganizationAccountAccessRole"
}

#------------------------------------------------------------------------------
# Summary (for easy reference)
#------------------------------------------------------------------------------
output "account_summary" {
  description = "Summary of all accounts for reference"
  value = {
    management = {
      id   = aws_organizations_organization.org.master_account_id
      type = "Management"
    }
    shared_services = {
      id          = aws_organizations_account.shared_services.id
      name        = aws_organizations_account.shared_services.name
      ou          = "Infrastructure"
      assume_role = "arn:aws:iam::${aws_organizations_account.shared_services.id}:role/OrganizationAccountAccessRole"
    }
    workload = {
      id          = aws_organizations_account.workload.id
      name        = aws_organizations_account.workload.name
      ou          = "Workloads"
      assume_role = "arn:aws:iam::${aws_organizations_account.workload.id}:role/OrganizationAccountAccessRole"
    }
    log_archive = {
      id          = aws_organizations_account.log_archive.id
      name        = aws_organizations_account.log_archive.name
      ou          = "Security"
      assume_role = "arn:aws:iam::${aws_organizations_account.log_archive.id}:role/OrganizationAccountAccessRole"
    }

  }
}
