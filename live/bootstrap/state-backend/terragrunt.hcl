# ---------------------------------------------------------------------------------------------------------------------
# STATE BACKEND BOOTSTRAP
# Creates the S3 bucket and DynamoDB table for Terraform state management
#
# IMPORTANT: This module must be deployed FIRST before any other modules.
# It uses a local backend initially, then can be migrated to S3 after creation.
#
# Bootstrap steps:
#   1. Deploy with local backend: terragrunt apply
#   2. Uncomment the remote_state block below
#   3. Migrate state: terragrunt init -migrate-state
# ---------------------------------------------------------------------------------------------------------------------

# Read common configuration
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# INITIAL BOOTSTRAP: Use local backend
# After the S3 bucket is created, comment out this block and uncomment the remote_state block below
# ---------------------------------------------------------------------------------------------------------------------
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# POST-BOOTSTRAP: Uncomment this block after the S3 bucket is created, then run:
#   terragrunt init -migrate-state
# ---------------------------------------------------------------------------------------------------------------------
# remote_state {
#   backend = "s3"
#
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
#
#   config = {
#     bucket         = local.common_vars.locals.state_bucket_name
#     key            = "lucid-aws-import/bootstrap/state-backend/terraform.tfstate"
#     region         = local.common_vars.locals.state_bucket_region
#     encrypt        = true
#     dynamodb_table = local.common_vars.locals.state_lock_table
#   }
# }

# ---------------------------------------------------------------------------------------------------------------------
# PROVIDER CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.common_vars.locals.state_bucket_region}"

  default_tags {
    tags = {
      ManagedBy   = "Terragrunt"
      Project     = "lucid-aws-import"
      Environment = "bootstrap"
    }
  }
}
EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
EOF
}

# Source the module
terraform {
  source = "${get_repo_root()}/modules/state-backend"
}

inputs = {
  bucket_name         = local.common_vars.locals.state_bucket_name
  dynamodb_table_name = local.common_vars.locals.state_lock_table

  tags = {
    Purpose = "Terraform state backend for Lucid AWS import"
  }
}
