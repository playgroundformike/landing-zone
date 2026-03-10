# Input variables for guardduty
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "log_archive_account_id" {
  description = "Account ID of the Log Archive account (GuardDuty admin)"
  type        = string
}