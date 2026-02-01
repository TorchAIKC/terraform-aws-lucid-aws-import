# ---------------------------------------------------------------------------------------------------------------------
# MEMBER ACCOUNTS CONFIGURATION
# Common configuration for all member accounts where import roles are deployed
# Individual account configurations can be overridden in each account's subfolder
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_name = "member"
  aws_region   = "us-east-1"
}
