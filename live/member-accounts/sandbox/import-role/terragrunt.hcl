# ---------------------------------------------------------------------------------------------------------------------
# IMPORT ROLE - WORKLOAD PROD
# Deploys the Lucid import IAM role in the workload-prod member account
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/import-role"
}

locals {
  common_vars  = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  bastion_vars = read_terragrunt_config("${get_repo_root()}/live/bastion-account/account.hcl")
}

inputs = {
  role_name              = local.common_vars.locals.member_account_role_name
  policy_name            = local.common_vars.locals.member_policy_name
  assume_role_account_id = local.bastion_vars.locals.account_id
  non_org_import         = false
  external_id            = null
}
