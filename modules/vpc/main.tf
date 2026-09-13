# =========================
# VPC
# =========================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.name
  }
}


# =========================
# Internet Gateway
# =========================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}


# =========================
# Public Subnets
# =========================

resource "aws_subnet" "public" {
  count = 3

  vpc_id = aws_vpc.main.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index + 1
  )

  availability_zone = var.azs[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}


# =========================
# Private Subnets
# =========================

resource "aws_subnet" "private" {
  count = 3

  vpc_id = aws_vpc.main.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index + 11
  )

  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}


# =========================
# Public Route Table
# =========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}


# =========================
# Public Route Table Associations
# =========================

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# =========================
# Elastic IP for NAT Gateway
# =========================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }
}


# =========================
# NAT Gateway
# =========================

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id

  # NAT Gateway must be inside a PUBLIC subnet
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}


# =========================
# Private Route Table
# =========================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.name}-private-rt"
  }
}


# =========================
# Private Route Table Associations
# =========================

resource "aws_route_table_association" "private" {
  count = 3

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}