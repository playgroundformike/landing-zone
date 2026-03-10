output "securityhub_account_id" {
  description = "The Security Hub account ID"
  value       = aws_securityhub_account.this.id
}