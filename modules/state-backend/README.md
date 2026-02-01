# State Backend Module

This module creates an S3 bucket and DynamoDB table for Terraform/Terragrunt remote state management.

## Features

- S3 bucket with versioning enabled
- Server-side encryption (AES256 or KMS)
- Public access blocked
- TLS enforced via bucket policy
- DynamoDB table for state locking with point-in-time recovery
- Lifecycle protection to prevent accidental deletion

## Usage

```hcl
module "state_backend" {
  source = "./modules/state-backend"

  bucket_name         = "my-terraform-state"
  dynamodb_table_name = "terraform-state-lock"

  tags = {
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}
```

## Bootstrap Process

This module creates the backend infrastructure that Terragrunt uses for state storage. To bootstrap:

1. Deploy this module first with local state:
   ```bash
   cd live/bootstrap/state-backend
   terragrunt apply
   ```

2. The state for this module will be stored locally initially, then migrated to S3.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | The name of the S3 bucket for state storage | `string` | n/a | yes |
| dynamodb_table_name | The name of the DynamoDB table for locking | `string` | n/a | yes |
| kms_key_arn | ARN of KMS key for encryption (optional) | `string` | `null` | no |
| enable_point_in_time_recovery | Enable PITR for DynamoDB | `bool` | `true` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket | S3 bucket details (id, arn, bucket, region) |
| dynamodb_table | DynamoDB table details (id, arn, name) |
