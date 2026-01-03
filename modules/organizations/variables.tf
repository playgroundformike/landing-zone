# Variables for Organizations Module

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

#------------------------------------------------------------------------------
# Shared Services Account
#------------------------------------------------------------------------------
variable "shared_services_account_name" {
  description = "Name for the Shared Services account"
  type        = string
  default     = "Shared-Services"

  validation {
    condition     = length(var.shared_services_account_name) <= 50
    error_message = "must be less than  50 characters"
  }
}

variable "shared_services_account_email" {
  description = "Email for the Shared Services account (must be unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.shared_services_account_email))
    error_message = "Must be a valid email address."

  }

}

#------------------------------------------------------------------------------
# Workload Account
#------------------------------------------------------------------------------
variable "workload_account_name" {
  description = "Name for the Workload account"
  type        = string
  default     = "Workload-Dev"
}

variable "workload_account_email" {
  description = "Email for the Workload account (must be unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.workload_account_email))
    error_message = "Must be a valid email address."
  }
}


#------------------------------------------------------------------------------
# Log Archive Account
#------------------------------------------------------------------------------
variable "workload_account_name" {
  description = "Name for the Workload account"
  type        = string
  default     = "Workload-Dev"
}

variable "workload_account_email" {
  description = "Email for the Workload account (must be unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.workload_account_email))
    error_message = "Must be a valid email address."
  }
}
