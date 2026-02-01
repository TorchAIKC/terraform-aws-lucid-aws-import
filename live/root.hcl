# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT ROOT CONFIGURATION
# This file contains the shared configuration for all Terragrunt units in this repository.
# All units should include this file using: include "root" { path = find_in_parent_folders("root.hcl") }
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Parse account-level configuration
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  account_name = local.account_vars.locals.account_name
  aws_region   = local.account_vars.locals.aws_region

  # Parse common variables
  common_vars         = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  external_id         = local.common_vars.locals.external_id
  state_bucket_name   = local.common_vars.locals.state_bucket_name
  state_lock_table    = local.common_vars.locals.state_lock_table
  state_bucket_region = local.common_vars.locals.state_bucket_region
}

# ---------------------------------------------------------------------------------------------------------------------
# REMOTE STATE BACKEND
# Configure S3 backend for Terraform state with DynamoDB locking
# NOTE: The state bucket must be created first using the bootstrap/state-backend module
# ---------------------------------------------------------------------------------------------------------------------
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = local.state_bucket_name
    key            = "lucid-aws-import/${path_relative_to_include()}/terraform.tfstate"
    region         = local.state_bucket_region
    encrypt        = true
    dynamodb_table = local.state_lock_table

    # Skip bucket creation - we manage the bucket via the state-backend module
    skip_bucket_versioning             = true
    skip_bucket_ssencryption           = true
    skip_bucket_root_access            = true
    skip_bucket_enforced_tls           = true
    skip_bucket_public_access_blocking = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS PROVIDER CONFIGURATION
# Generate the AWS provider configuration for each unit
# ---------------------------------------------------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      ManagedBy   = "Terragrunt"
      Project     = "lucid-aws-import"
      Environment = "${local.account_name}"
    }
  }
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM VERSION CONSTRAINTS
# ---------------------------------------------------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------------------------------------------------
# COMMON INPUTS
# These inputs are passed to all modules
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  # Common tags can be added here and will be merged with module-specific inputs
}
