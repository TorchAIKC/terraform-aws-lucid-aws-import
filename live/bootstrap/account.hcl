# ---------------------------------------------------------------------------------------------------------------------
# BOOTSTRAP ACCOUNT CONFIGURATION
# This is the account where the Terraform state backend (S3 + DynamoDB) is deployed
# Typically this is your management account or a dedicated shared-services account
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_name = "bootstrap"
  account_id   = "806441233035"  # Account where state bucket lives
  aws_region   = "us-east-1"
}
