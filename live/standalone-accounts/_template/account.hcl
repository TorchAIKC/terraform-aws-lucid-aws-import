# ---------------------------------------------------------------------------------------------------------------------
# STANDALONE ACCOUNT CONFIGURATION TEMPLATE
# Copy this folder for each standalone (non-org) account
# These accounts connect directly to Lucid's proxy account
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_name = "__FILL_IN_ACCOUNT_NAME__"  # e.g., "sandbox"
  account_id   = "__FILL_IN_ACCOUNT_ID__"    # e.g., "123456789016"
  aws_region   = "us-east-1"
}
