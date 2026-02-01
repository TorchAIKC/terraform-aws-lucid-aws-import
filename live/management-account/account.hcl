# ---------------------------------------------------------------------------------------------------------------------
# MANAGEMENT ACCOUNT CONFIGURATION
# This is the AWS Organizations management account where org-read-delegation is configured
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_name = "management"
  account_id   = "806441233035"  # e.g., "123456789012"
  aws_region   = "us-east-1"
}
