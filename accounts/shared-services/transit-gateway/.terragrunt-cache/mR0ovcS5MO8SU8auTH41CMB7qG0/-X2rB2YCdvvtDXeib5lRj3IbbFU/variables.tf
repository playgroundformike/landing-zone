# Variables for Transit Gateway Module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "share_with_account_ids" {
  description = "List of account IDs to share the Transit Gateway with"
  type        = list(string)
  default     = []
}
