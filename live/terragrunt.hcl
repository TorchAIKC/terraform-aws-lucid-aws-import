# ---------------------------------------------------------------------------------------------------------------------
# ROOT TERRAGRUNT CONFIGURATION
# This file enables stack operations across all units using `terragrunt run --all`
#
# IMPORTANT: This configuration assumes you have appropriate AWS credentials configured
# for each account. For multi-account deployments, you'll typically run each account
# separately or use AWS profiles/role assumption.
# ---------------------------------------------------------------------------------------------------------------------

# Skip this directory when running `terragrunt run --all` from here
# This prevents the root from being treated as a deployable unit
skip = true
