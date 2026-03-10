# Main resources for security-hub
#------------------------------------------------------------------------------
# Security Hub - Organization Administrator
#------------------------------------------------------------------------------
resource "aws_securityhub_account" "this" {
  enable_default_standards = false

  lifecycle {
    # prevent_destroy = true
  }
}

resource "aws_securityhub_organization_configuration" "this" {
  auto_enable           = true
  auto_enable_standards = "DEFAULT"
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.this]
}
