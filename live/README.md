# Terragrunt Live Configuration

This directory contains the Terragrunt wrapper configuration for deploying Lucid AWS import roles across your AWS Organization.

## Directory Structure

```
live/
├── root.hcl                          # Shared backend/provider configuration
├── common.hcl                        # Common variables (external_id, role names, state bucket)
├── terragrunt.hcl                    # Root stack configuration
│
├── bootstrap/                        # Bootstrap resources (deploy first!)
│   ├── account.hcl                   # Bootstrap account configuration
│   └── state-backend/                # S3 bucket + DynamoDB for state
│       └── terragrunt.hcl
│
├── management-account/               # AWS Organizations management account
│   ├── account.hcl                   # Account-specific configuration
│   └── org-read-delegation/          # Delegates org read access to bastion
│       └── terragrunt.hcl
│
├── bastion-account/                  # Dedicated bastion account
│   ├── account.hcl                   # Account-specific configuration
│   └── bastion-role/                 # Lucid import bastion role
│       └── terragrunt.hcl
│
├── member-accounts/                  # Member accounts (org imports)
│   ├── account.hcl                   # Common member account config
│   ├── _template/                    # Template for new member accounts
│   │   ├── account.hcl
│   │   └── import-role/
│   │       └── terragrunt.hcl
│   ├── workload-prod/                # Example: production workload account
│   │   ├── account.hcl
│   │   └── import-role/
│   │       └── terragrunt.hcl
│   └── workload-dev/                 # Example: development workload account
│       ├── account.hcl
│       └── import-role/
│           └── terragrunt.hcl
│
└── standalone-accounts/              # Standalone accounts (non-org imports)
    ├── account.hcl                   # Common standalone config
    └── _template/                    # Template for standalone accounts
        ├── account.hcl
        └── import-role/
            └── terragrunt.hcl
```

## Prerequisites

1. **Terragrunt installed**: `brew install terragrunt` (macOS) or see [Terragrunt installation docs](https://terragrunt.gruntwork.io/docs/getting-started/install/)
2. **Terraform/OpenTofu installed**: Terragrunt requires Terraform >= 1.0 or OpenTofu
3. **AWS credentials configured**: Either via environment variables, AWS profiles, or IAM roles

## Initial Setup

### 1. Configure common.hcl

Update `live/common.hcl` with your configuration:

```hcl
locals {
  # Lucid external ID
  external_id = "your-lucid-external-id"

  # State backend configuration
  state_bucket_name   = "your-org-lucid-import-tfstate"
  state_lock_table    = "lucid-import-tfstate-lock"
  state_bucket_region = "us-east-1"
}
```

### 2. Configure Account IDs

Update the `account.hcl` files in each account directory with the appropriate AWS account IDs:

- `bootstrap/account.hcl` - Account where state bucket will be created
- `management-account/account.hcl` - Management account ID
- `bastion-account/account.hcl` - Bastion account ID
- `member-accounts/*/account.hcl` - Each member account ID

### 3. Bootstrap the State Backend

The state-backend module creates the S3 bucket and DynamoDB table for Terraform state:

```bash
cd live/bootstrap/state-backend
terragrunt apply
```

After the bucket is created, migrate the bootstrap state to S3:
1. Edit `live/bootstrap/state-backend/terragrunt.hcl`
2. Comment out the `generate "backend"` block
3. Uncomment the `remote_state` block
4. Run `terragrunt init -migrate-state`

## Deployment Order

For organization-wide imports, deploy in this order:

1. **Management Account** - Org read delegation policy
2. **Bastion Account** - Bastion role
3. **Member Accounts** - Import roles

### Deploy to Management Account

```bash
cd live/management-account/org-read-delegation
terragrunt plan
terragrunt apply
```

### Deploy to Bastion Account

```bash
cd live/bastion-account/bastion-role
terragrunt plan
terragrunt apply
```

### Deploy to Member Accounts

```bash
# Deploy to a specific member account
cd live/member-accounts/workload-prod/import-role
terragrunt plan
terragrunt apply

# Or deploy to all member accounts at once
cd live/member-accounts
terragrunt run --all plan
terragrunt run --all apply
```

## Adding New Member Accounts

1. Copy the template directory:
   ```bash
   cp -r live/member-accounts/_template live/member-accounts/new-account-name
   ```

2. Update `live/member-accounts/new-account-name/account.hcl`:
   ```hcl
   locals {
     account_name = "new-account-name"
     account_id   = "123456789012"
     aws_region   = "us-east-1"
   }
   ```

3. Deploy:
   ```bash
   cd live/member-accounts/new-account-name/import-role
   terragrunt apply
   ```

## Standalone (Non-Org) Imports

For accounts outside AWS Organizations:

1. Copy the standalone template:
   ```bash
   cp -r live/standalone-accounts/_template live/standalone-accounts/my-standalone
   ```

2. Update the `account.hcl` with the account details

3. Deploy:
   ```bash
   cd live/standalone-accounts/my-standalone/import-role
   terragrunt apply
   ```

## Multi-Account Authentication

For deploying across multiple AWS accounts, you have several options:

### Option 1: AWS Profiles

Configure AWS profiles in `~/.aws/credentials` and set `AWS_PROFILE` before running:

```bash
export AWS_PROFILE=management-account
cd live/management-account/org-read-delegation
terragrunt apply
```

### Option 2: Assume Role

Add provider configuration with assume role in `root.hcl`:

```hcl
generate "provider" {
  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/TerraformRole"
  }
}
EOF
}
```

### Option 3: CI/CD Pipeline

Use your CI/CD platform's AWS integration to assume roles per account.

## Useful Commands

```bash
# Validate configuration
terragrunt validate

# Plan changes
terragrunt plan

# Apply changes
terragrunt apply

# Destroy resources
terragrunt destroy

# Run against all units in current directory
terragrunt run --all plan
terragrunt run --all apply

# Show the dependency graph
terragrunt graph-dependencies

# Format all HCL files
terragrunt hclfmt
```

## Troubleshooting

### State Backend Errors

If you see "Backend configuration changed" errors:
```bash
terragrunt init -migrate-state
```

### Module Source Errors

Ensure you're running from the correct directory with access to the modules:
```bash
# Check the module path resolves correctly
terragrunt render-json | jq '.terraform.source'
```

### Dependency Errors

If dependencies fail to resolve outputs, ensure mock_outputs are configured:
```hcl
dependency "example" {
  config_path = "../other-unit"
  mock_outputs = {
    output_name = "mock-value"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}
```
