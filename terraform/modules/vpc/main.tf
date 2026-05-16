resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public subnets

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Web subnets

resource "aws_subnet" "web" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-web-subnet-${count.index + 1}"
  }
}

# App subnets

resource "aws_subnet" "app" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.app_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-app-subnet-${count.index + 1}"
  }
}

# DB subnets

resource "aws_subnet" "db" {
  count = 2

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-db-subnet-${count.index + 1}"
  }
}

# Elastic IPs

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}

# NAT Gateways

resource "aws_nat_gateway" "this" {
  count = 2

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-nat-gateway-${count.index + 1}"
  }
}

# Public Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Web Route Tables

resource "aws_route_table" "web" {
  count  = 2
  vpc_id = aws_vpc.this.id
  depends_on = [aws_nat_gateway.this]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.project_name}-web-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "web" {
  count = 2

  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.web[count.index].id
}

# App Route Tables

resource "aws_route_table" "app" {
  count  = 2
  vpc_id = aws_vpc.this.id
  depends_on = [aws_nat_gateway.this]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.project_name}-app-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "app" {
  count = 2

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# DB Route Tables

resource "aws_route_table" "db" {
  count  = 2
  vpc_id = aws_vpc.this.id

  tags ={
    Name = "${var.project_name}-db-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "db" {
  count = 2

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}