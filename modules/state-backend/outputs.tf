output "bucket" {
  description = "The S3 bucket for Terraform state"
  value = {
    id     = aws_s3_bucket.state.id
    arn    = aws_s3_bucket.state.arn
    bucket = aws_s3_bucket.state.bucket
    region = data.aws_region.current.name
  }
}

output "dynamodb_table" {
  description = "The DynamoDB table for Terraform state locking"
  value = {
    id   = aws_dynamodb_table.lock.id
    arn  = aws_dynamodb_table.lock.arn
    name = aws_dynamodb_table.lock.name
  }
}
