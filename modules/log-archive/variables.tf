variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "log_archive_account_id" {
  description = "Account ID of the Log Archive account"
  type        = string
}

variable "organization_id" {
  description = "AWS Organization ID"
  type        = string
}

variable "organization_account_ids" {
  description = "List of all account IDs in the organization (for KMS decrypt permissions)"
  type        = list(string)
}