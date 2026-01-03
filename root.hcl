# Root Terragrunt configuration
# All child configurations inherit from this

locals {
  # Project-wide settings
  project_name = "landing-zone"
  
  # AWS Region - using us-east-1
  # AWS Organizations is a global service, but its API endpoint is ONLY in us-east-1
  aws_region = "us-east-1"

  # Dynamically get the AWS account ID
  account_id = get_aws_account_id()
  
  # State bucket configuration
  # IMPORTANT: Replace with your unique bucket name
  # Reference other locals with the "local." prefix 
    state_bucket = "tfstate-management-${local.account_id}-${local.aws_region}"
 
  # DynamoDB table for state locking
  lock_table = "terraform-locks"

  # Parse environment from folder path
  path_parts  = split("/", path_relative_to_include())
  account_name  = local.path_parts[1]   

}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  
  default_tags {
    tags = {
      Project     = "${local.project_name}"
      ManagedBy   = "Terraform"
      account_name  = "${local.account_name}"
    }
  }
}
EOF
}

# Remote state configuration
remote_state {
  backend = "s3"
  
  config = {
    bucket         = local.state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = local.lock_table
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Common inputs passed to all modules
inputs = {
  project_name = local.project_name
  aws_region   = local.aws_region
}
