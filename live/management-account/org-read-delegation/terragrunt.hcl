# ---------------------------------------------------------------------------------------------------------------------
# ORG READ DELEGATION
# Deploys an AWS Organizations resource policy to delegate read access to the bastion account
# This must be run in the AWS Organizations management account
# ---------------------------------------------------------------------------------------------------------------------

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Source the module from the local modules directory
terraform {
  source = "${get_repo_root()}/modules/org-read-delegation"
}

# Read bastion account configuration to get the account ID
locals {
  bastion_account_vars = read_terragrunt_config("${get_repo_root()}/live/bastion-account/account.hcl")
  bastion_account_id   = local.bastion_account_vars.locals.account_id
}

inputs = {
  # Use existing bastion account - provide the account ID
  account_id = local.bastion_account_id

  # If you want Terraform to create a new bastion account instead, comment out account_id above
  # and uncomment the following:
  # account_id    = null
  # account_name  = "lucid-import-bastion"
  # account_email = "lucid-bastion@yourcompany.com"
  # parent_id     = "ou-xxxx-xxxxxxxx"  # Organizational Unit ID or root ID
}
