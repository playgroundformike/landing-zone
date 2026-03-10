output "cloudtrail_bucket_id" {
  description = "The name of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_bucket_arn" {
  description = "The ARN of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "cloudtrail_kms_key_id" {
  description = "The ID of the KMS key used for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.id
}

output "cloudtrail_kms_key_arn" {
  description = "The ARN of the KMS key used for CloudTrail encryption"
  value       = aws_kms_key.cloudtrail.arn
}

output "cloudtrail_id" {
  description = "The ID of the organization CloudTrail"
  value       = aws_cloudtrail.org.id
}

output "cloudtrail_arn" {
  description = "The ARN of the organization CloudTrail"
  value       = aws_cloudtrail.org.arn
}

output "flow_logs_bucket_arn" {
  description = "ARN of the Flow Logs S3 bucket"
  value       = aws_s3_bucket.flow_logs.arn
}

output "flow_logs_bucket_name" {
  description = "Name of the Flow Logs S3 bucket"
  value       = aws_s3_bucket.flow_logs.id
}
 