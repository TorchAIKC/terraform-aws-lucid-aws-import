# ---------------------------------------------------------------------------------------------------------------------
# IMPORT ROLE (STANDALONE / NON-ORG ACCOUNT)
# Deploys the Lucid import IAM role for a standalone account (not part of AWS Organizations)
# This role is assumed directly by Lucid's AWS proxy account using the external ID
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/import-role"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  # Lucid's AWS import proxy account IDs
  # Commercial: 799803075172
  # GovCloud:   239369393023
  lucid_proxy_account_id = "799803075172"
}

inputs = {
  role_name   = local.common_vars.locals.member_account_role_name
  policy_name = local.common_vars.locals.member_policy_name

  # For non-org imports, Lucid's proxy account directly assumes this role
  assume_role_account_id = local.lucid_proxy_account_id

  # Non-org import requires external ID for secure access
  non_org_import = true
  external_id    = local.common_vars.locals.external_id
}
