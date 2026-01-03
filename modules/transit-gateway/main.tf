# Transit Gateway Module
# Creates the central hub for VPC-to-VPC connectivity

#------------------------------------------------------------------------------
# Transit Gateway
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "main" {
  description = "Central Transit Gateway for ${var.project_name}"

  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "${var.project_name}-tgw"
  }
}

#------------------------------------------------------------------------------
# RAM Resource Share - Share TGW with specific accounts
#------------------------------------------------------------------------------
resource "aws_ram_resource_share" "tgw" {
  name                      = "${var.project_name}-tgw-share"
  allow_external_principals = true

  tags = {
    Name = "${var.project_name}-tgw-share"
  }
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.main.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

# Share with each account ID (sends invitation)
resource "aws_ram_principal_association" "accounts" {
  for_each           = toset(var.share_with_account_ids)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw.arn
}
