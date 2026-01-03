# Outputs for VPC Module

#------------------------------------------------------------------------------
# VPC Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

#------------------------------------------------------------------------------
# Subnet Outputs
#------------------------------------------------------------------------------
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "tgw_subnet_ids" {
  description = "IDs of TGW subnets"
  value       = aws_subnet.tgw[*].id
}

#------------------------------------------------------------------------------
# Route Table Outputs
#------------------------------------------------------------------------------
output "public_route_table_id" {
  description = "ID of public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of private route table"
  value       = aws_route_table.private.id
}

output "tgw_route_table_id" {
  description = "ID of TGW route table"
  value       = aws_route_table.tgw.id
}

#------------------------------------------------------------------------------
# TGW Attachment Output
#------------------------------------------------------------------------------
output "tgw_attachment_id" {
  description = "ID of the TGW attachment (if created)"
  value       = var.create_tgw_attachment ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

#------------------------------------------------------------------------------
# NAT Gateway Output
#------------------------------------------------------------------------------
output "nat_gateway_id" {
  description = "ID of the NAT Gateway (if created)"
  value       = var.create_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway (if created)"
  value       = var.create_nat_gateway ? aws_eip.nat[0].public_ip : null
}
