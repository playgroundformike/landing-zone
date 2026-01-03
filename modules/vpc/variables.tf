# Variables for VPC Module

#------------------------------------------------------------------------------
# Core VPC Variables
#------------------------------------------------------------------------------
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., shared-services, workload)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

#------------------------------------------------------------------------------
# Transit Gateway Variables
#------------------------------------------------------------------------------
variable "create_tgw_attachment" {
  description = "Whether to create Transit Gateway attachment"
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach to"
  type        = string
  default     = ""
}

variable "tgw_destination_cidrs" {
  description = "List of CIDR blocks to route through TGW"
  type        = list(string)
  default     = []
}

variable "accept_ram_share" {
  description = "Whether to accept a RAM resource share (needed for cross-account TGW)"
  type        = bool
  default     = false
}

variable "ram_resource_share_arn" {
  description = "ARN of the RAM resource share to accept"
  type        = string
  default     = ""
}

#------------------------------------------------------------------------------
# NAT Gateway Variable
#------------------------------------------------------------------------------
variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway for private subnet internet access"
  type        = bool
  default     = false
}
