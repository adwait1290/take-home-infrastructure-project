# Use locals for defining common tags for resource identification and environment isolation.
# It helps in efficient resource management and is a best-practice recommendation.
locals {
  common_tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
  }
}

# Fetching the availability zones in the region that are currently available
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true # Enable DNS support
  enable_dns_hostnames = true # Enable DNS hostname resolution
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway - Required to give our VPC access to the outside world
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Public Subnets - Used typically for frontend webservers. As they accept incoming traffic.
# cidrsubnet() calculates a subnet address within our given vpc_cidr range
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index}"
  }
}

# Private Subnets - Used typically for backend servers that don't need to accept incoming traffic.
# cidrsubnet() calculates a subnet address within our given vpc_cidr range
resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + length(aws_subnet.public))

  tags = {
    Name = "PrivateSubnet-${count.index}"
  }
}

# NAT Gateway - Required for outbound internet access from our private subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.for_nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.gw]
}

# Elastic IP for NAT Gateway - Required for NAT Gateway setup
resource "aws_eip" "for_nat" {
  vpc = true
}

# Route table - Routes for our subnet traffic
# Public route table - routing traffic through internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                # IP range for all traffic
    gateway_id = aws_internet_gateway.gw.id # Internet Gateway for all outbound traffic
  }
}
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table - routing traffic through nat gateway for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"             # IP range for all traffic
    nat_gateway_id = aws_nat_gateway.main.id # NAT Gateway for all outbound traffic
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}