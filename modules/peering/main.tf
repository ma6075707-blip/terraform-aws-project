resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.vpc1_id
  peer_vpc_id = var.vpc2_id
  auto_accept = true

  tags = {
    Name = var.name
  }
}

# VPC1 Public Route Table → VPC2
resource "aws_route" "vpc1_public_to_vpc2" {
  route_table_id            = var.vpc1_public_route_table_id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# VPC1 Private Route Table → VPC2
resource "aws_route" "vpc1_private_to_vpc2" {
  route_table_id            = var.vpc1_private_route_table_id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# VPC2 Private Route Table → VPC1
resource "aws_route" "vpc2_private_to_vpc1" {
  route_table_id            = var.vpc2_private_route_table_id
  destination_cidr_block    = var.vpc1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}