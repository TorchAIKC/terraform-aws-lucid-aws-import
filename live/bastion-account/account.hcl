# ---------------------------------------------------------------------------------------------------------------------
# BASTION ACCOUNT CONFIGURATION
# This is the dedicated account where the Lucid bastion role is deployed
# The bastion role assumes roles in member accounts for imports
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_name = "bastion"
  account_id   = "806441233035"  # e.g., "123456789013"
  aws_region   = "us-east-1"
}
