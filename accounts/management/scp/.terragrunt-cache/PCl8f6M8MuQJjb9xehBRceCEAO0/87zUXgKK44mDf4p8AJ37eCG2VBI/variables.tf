# Variables for SCP Module

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

#------------------------------------------------------------------------------
# OU IDs (from Phase 1 outputs)
#------------------------------------------------------------------------------
variable "workloads_ou_id" {
  description = "ID of the Workloads OU"
  type        = string
}

variable "infrastructure_ou_id" {
  description = "ID of the Infrastructure OU"
  type        = string
}

#------------------------------------------------------------------------------
# Region Restriction
#------------------------------------------------------------------------------
variable "allowed_regions" {
  description = "List of AWS regions where resources can be created"
  type        = list(string)
  default     = ["us-east-1", "us-east-2"]

  validation {
    condition     = length(var.allowed_regions) > 0
    error_message = "At least one region must be allowed."
  }


  validation {
    condition = alltrue([
      for region in var.allowed_regions : contains(
        ["us-east-1", "us-east-2", "us-west-1", "us-west-2"], # Valid regions
        region
      )
    ])
    error_message = "All regions must be valid AWS region names."
  }

}

#------------------------------------------------------------------------------
# Security Admin Exception
#------------------------------------------------------------------------------
variable "security_admin_role_patterns" {
  description = "ARN patterns for roles that can modify security controls"
  type        = list(string)
  default = [
    "arn:aws:iam::*:role/OrganizationAccountAccessRole",
    "arn:aws:iam::*:role/SecurityAdmin"
  ]
}
