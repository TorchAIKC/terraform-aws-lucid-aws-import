# ---------------------------------------------------------------------------------------------------------------------
# STANDALONE ACCOUNTS CONFIGURATION
# Common configuration for standalone accounts (non-org imports)
# These accounts connect directly to Lucid without going through a bastion account
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_name = "standalone"
  aws_region   = "us-east-1"
}
