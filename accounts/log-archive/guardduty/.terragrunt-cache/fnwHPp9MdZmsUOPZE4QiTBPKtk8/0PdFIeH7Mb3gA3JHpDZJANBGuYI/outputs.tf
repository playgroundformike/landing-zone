# Output values for guardduty
output "guardduty_detector_id" {
  description = "The GuardDuty detector ID"
  value       = aws_guardduty_detector.this.id
}

output "guardduty_detector_arn" {
  description = "The GuardDuty detector ARN"
  value       = aws_guardduty_detector.this.arn
}