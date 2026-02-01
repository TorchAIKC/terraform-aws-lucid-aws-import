# ---------------------------------------------------------------------------------------------------------------------
# BASTION ROLE
# Deploys the Lucid import bastion IAM role that can be assumed by Lucid's AWS proxy account
# This role has permissions to:
#   - Assume the import role in member accounts
#   - Read AWS Organizations data
# This must be run in the bastion account
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Source the module from the local modules directory
terraform {
  source = "${get_repo_root()}/modules/bastion-role"
}

# Read common configuration for role names and external ID
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

# Dependency on org-read-delegation (optional - ensures org policy is in place first)
# Uncomment if deploying everything together with `terragrunt run --all`
# dependency "org_read_delegation" {
#   config_path = "../../management-account/org-read-delegation"
#
#   mock_outputs = {
#     bastion_account_id = "000000000000"
#   }
#   mock_outputs_allowed_terraform_commands = ["validate", "plan"]
# }

inputs = {
  # Role configuration
  bastion_role_name        = local.common_vars.locals.bastion_role_name
  member_account_role_name = local.common_vars.locals.member_account_role_name
  role_policy_name         = local.common_vars.locals.bastion_policy_name

  # External ID for secure cross-account access (from Lucid)
  external_id = local.common_vars.locals.external_id
}
