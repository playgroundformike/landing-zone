# Service Control Policies (SCPs) Module
# Implements preventive guardrails across the organization

#------------------------------------------------------------------------------
# Data source to get organization info
#------------------------------------------------------------------------------

# Reads information about your existing organization.

data "aws_organizations_organization" "org" {}

#------------------------------------------------------------------------------
# SCP 1: Deny Leave Organization
# Prevents member accounts from leaving the organization
# Maps to: NIST AC-2 (Account Management)
#------------------------------------------------------------------------------
resource "aws_organizations_policy" "deny_leave_org" {
  name        = "DenyLeaveOrganization"
  description = "Prevents accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })

  tags = {
    Purpose    = "Prevent account removal"
    Compliance = "AC-2"
  }
}

# Attach to root - applies to ALL accounts
resource "aws_organizations_policy_attachment" "deny_leave_org_root" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = data.aws_organizations_organization.org.roots[0].id
}

#------------------------------------------------------------------------------
# SCP 2: Deny Unapproved Regions
# Restricts resource creation to approved regions only
# Maps to: NIST CM-7 (Least Functionality), data residency requirements
#------------------------------------------------------------------------------
resource "aws_organizations_policy" "deny_regions" {
  name        = "DenyUnapprovedRegions"
  description = "Restricts actions to approved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyUnapprovedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })

  tags = {
    Purpose    = "Region restriction"
    Compliance = "CM-7"
  }
}

# Attach to Workloads OU only (Shared Services may need multi-region)
resource "aws_organizations_policy_attachment" "deny_regions_workloads" {
  policy_id = aws_organizations_policy.deny_regions.id
  target_id = var.workloads_ou_id
}

#------------------------------------------------------------------------------
# SCP 3: Protect Security Controls
# Prevents disabling CloudTrail, Config, GuardDuty, etc.
# Maps to: NIST AU-9 (Protection of Audit Information)
#------------------------------------------------------------------------------
resource "aws_organizations_policy" "protect_security" {
  name        = "ProtectSecurityControls"
  description = "Prevents disabling security services and audit logging"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors"
        ]
        Resource = "*"
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = var.security_admin_role_patterns
          }
        }
      },
      {
        Sid    = "ProtectConfig"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigRule",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = var.security_admin_role_patterns
          }
        }
      },
      {
        Sid    = "ProtectGuardDuty"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers",
          "guardduty:StopMonitoringMembers"
        ]
        Resource = "*"
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = var.security_admin_role_patterns
          }
        }
      },
      {
        Sid    = "DenyS3PublicAccess"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
          "s3:DeletePublicAccessBlock"
        ]
        Resource = "*"
        Condition = {
          StringNotLike = {
            "aws:PrincipalArn" = var.security_admin_role_patterns
          }
        }
      }
    ]
  })

  tags = {
    Purpose    = "Protect audit and security controls"
    Compliance = "AU-9"
  }
}

# Attach to root - applies to ALL member accounts
resource "aws_organizations_policy_attachment" "protect_security_root" {
  policy_id = aws_organizations_policy.protect_security.id
  target_id = data.aws_organizations_organization.org.roots[0].id
}

#------------------------------------------------------------------------------
# SCP 4: Deny Root User Actions
# Blocks root user from performing actions in member accounts
# Maps to: NIST AC-6 (Least Privilege)
#------------------------------------------------------------------------------
resource "aws_organizations_policy" "deny_root_user" {
  name        = "DenyRootUserActions"
  description = "Prevents root user from performing actions in member accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })

  tags = {
    Purpose    = "Deny root user actions"
    Compliance = "AC-6"
  }
}

# Attach to Workloads OU
resource "aws_organizations_policy_attachment" "deny_root_workloads" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = var.workloads_ou_id
}

# Attach to Infrastructure OU
resource "aws_organizations_policy_attachment" "deny_root_infrastructure" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = var.infrastructure_ou_id
}
