# Outputs for Transit Gateway Module

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.arn
}

output "ram_resource_share_arn" {
  description = "ARN of the RAM resource share"
  value       = aws_ram_resource_share.tgw.arn
}

output "ram_principal_associations" {
  description = "Map of account IDs to their RAM principal association IDs"
  value       = { for k, v in aws_ram_principal_association.accounts : k => v.id }
}
