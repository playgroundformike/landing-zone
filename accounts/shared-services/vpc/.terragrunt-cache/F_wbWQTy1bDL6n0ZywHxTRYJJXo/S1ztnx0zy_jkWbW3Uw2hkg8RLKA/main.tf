# VPC Module
# Reusable VPC with public, private, and TGW subnets

#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${var.availability_zones[count.index]}"
    Tier = "Public"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${var.availability_zones[count.index]}"
    Tier = "Private"
  }
}

# TGW Subnets (small /24 subnets starting at position 64)
resource "aws_subnet" "tgw" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 64 + count.index)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw-${var.availability_zones[count.index]}"
    Tier = "TGW"
  }
}

#------------------------------------------------------------------------------
# NAT Gateway (optional)
#------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

#------------------------------------------------------------------------------
# Route Tables
#------------------------------------------------------------------------------

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

resource "aws_route" "private_to_nat" {
  count = var.create_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# TGW Route Table
resource "aws_route_table" "tgw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw-rt"
  }
}

resource "aws_route_table_association" "tgw" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw.id
}

#------------------------------------------------------------------------------
# RAM Share Accepter (for accounts receiving shared TGW)
#------------------------------------------------------------------------------
resource "aws_ram_resource_share_accepter" "tgw" {
  count     = var.accept_ram_share ? 1 : 0
  share_arn = var.ram_resource_share_arn
}

#------------------------------------------------------------------------------
# Transit Gateway Attachment (optional)
#------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.create_tgw_attachment ? 1 : 0

  subnet_ids         = aws_subnet.tgw[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main.id

  dns_support  = "enable"
  ipv6_support = "disable"

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw-attachment"
  }

  depends_on = [aws_ram_resource_share_accepter.tgw]
}

#------------------------------------------------------------------------------
# Routes to Transit Gateway (optional)
#------------------------------------------------------------------------------
resource "aws_route" "private_to_tgw" {
  count = var.create_tgw_attachment ? length(var.tgw_destination_cidrs) : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.tgw_destination_cidrs[count.index]
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "tgw_to_nat" {
  count = var.create_tgw_attachment && var.create_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.tgw.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}
