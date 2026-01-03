# Outputs for SCP Module

# Best practice: output anything that identifies a resource. Costs nothing, helps later.

output "deny_leave_org_policy_id" {
  description = "ID of the Deny Leave Organization SCP"
  value       = aws_organizations_policy.deny_leave_org.id
}

output "deny_regions_policy_id" {
  description = "ID of the Deny Unapproved Regions SCP"
  value       = aws_organizations_policy.deny_regions.id
}

output "protect_security_policy_id" {
  description = "ID of the Protect Security Controls SCP"
  value       = aws_organizations_policy.protect_security.id
}

output "deny_root_user_policy_id" {
  description = "ID of the Deny Root User SCP"
  value       = aws_organizations_policy.deny_root_user.id
}

output "scp_summary" {
  description = "Summary of all SCPs created"
  value = {
    deny_leave_org = {
      id          = aws_organizations_policy.deny_leave_org.id
      name        = aws_organizations_policy.deny_leave_org.name
      attached_to = "Root (all accounts)"
    }
    deny_regions = {
      id          = aws_organizations_policy.deny_regions.id
      name        = aws_organizations_policy.deny_regions.name
      attached_to = "Workloads OU"
    }
    protect_security = {
      id          = aws_organizations_policy.protect_security.id
      name        = aws_organizations_policy.protect_security.name
      attached_to = "Root (all accounts)"
    }
    deny_root_user = {
      id          = aws_organizations_policy.deny_root_user.id
      name        = aws_organizations_policy.deny_root_user.name
      attached_to = "Workloads OU and Infrastructure OU"
    }
  }
}
