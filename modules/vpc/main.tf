# Retrieve available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# 1. VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# 3. Public Subnets (Load Balancer Layer)
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
  }
}

# 4. Private Subnets (App / EC2 Layer)
resource "aws_subnet" "private_app" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + var.az_count)
  availability_zone = local.selected_azs[count.index]

  tags = {
    Name        = "${var.environment}-app-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private-App"
  }
}

# 5. Isolated Subnets (Database Layer)
resource "aws_subnet" "private_db" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + (var.az_count * 2))
  availability_zone = local.selected_azs[count.index]

  tags = {
    Name        = "${var.environment}-db-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private-DB"
  }
}

# 6. Elastic IPs & NAT Gateways
resource "aws_eip" "nat" {
  count      = var.single_nat_gateway ? 1 : var.az_count
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name        = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.single_nat_gateway ? 1 : var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gw-${count.index + 1}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]
}

# 7. Route Tables & Associations

## Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

## Private App Route Tables
resource "aws_route_table" "private_app" {
  count  = var.az_count
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name        = "${var.environment}-app-rt-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_app" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

## Database Route Table (Isolated - No Direct Outbound Internet Access)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.environment}-db-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_db" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}

# 8. DB Subnet Group (Required for RDS deployment later)
resource "aws_db_subnet_group" "this" {
  name        = "${var.environment}-db-subnet-group"
  subnet_ids  = aws_subnet.private_db[*].id
  description = "Database subnet group for ${var.environment}"

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}