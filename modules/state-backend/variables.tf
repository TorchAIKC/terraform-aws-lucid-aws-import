variable "bucket_name" {
  description = "The name of the S3 bucket to create for Terraform state storage"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to create for Terraform state locking"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption. If not provided, AES256 encryption will be used"
  type        = string
  default     = null
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for the DynamoDB table"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
