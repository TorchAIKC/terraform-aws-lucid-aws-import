# ---------------------------------------------------------------------------------------------------------------------
# IMPORT ROLE (MEMBER ACCOUNT)
# Deploys the Lucid import IAM role in a member account
# This role can be assumed by the bastion role for organization-wide imports
# This must be run in each member account where you want Lucid to import resources
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Source the module from the local modules directory
terraform {
  source = "${get_repo_root()}/modules/import-role"
}

# Read common and account-specific configuration
locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  bastion_vars = read_terragrunt_config("${get_repo_root()}/live/bastion-account/account.hcl")
}

# Dependency on bastion role (optional - ensures bastion role exists first)
# Uncomment if deploying everything together with `terragrunt run --all`
# dependency "bastion_role" {
#   config_path = "../../../bastion-account/bastion-role"
#
#   mock_outputs = {
#     bastion_role = {
#       id   = "mock-role-id"
#       arn  = "arn:aws:iam::000000000000:role/mock-role"
#       name = "mock-role"
#     }
#   }
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
# }

inputs = {
  # Role configuration
  role_name   = local.common_vars.locals.member_account_role_name
  policy_name = local.common_vars.locals.member_policy_name

  # For org-level imports, the bastion account assumes this role
  assume_role_account_id = local.bastion_vars.locals.account_id

  # Not a non-org import (bastion role handles external ID)
  non_org_import = false
  external_id    = null
}
