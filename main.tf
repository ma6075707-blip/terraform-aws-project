
provider "aws" {
  region = "eu-west-1"
}

# =========================
# VPC 1
# =========================

module "vpc1" {
  source = "./modules/vpc"

  name     = "vpc1"
  vpc_cidr = "10.0.0.0/16"

  azs = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

# =========================
# VPC 2
# =========================

module "vpc2" {
  source = "./modules/vpc"

  name     = "vpc2"
  vpc_cidr = "10.1.0.0/16"

  azs = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}

# =========================
# VPC Peering
# =========================

module "peering" {
  source = "./modules/peering"

  name = "vpc1-vpc2-peering"

  vpc1_id = module.vpc1.vpc_id
  vpc2_id = module.vpc2.vpc_id

  vpc1_public_route_table_id  = module.vpc1.public_route_table_id
  vpc1_private_route_table_id = module.vpc1.private_route_table_id
  vpc2_private_route_table_id = module.vpc2.private_route_table_id

  vpc1_cidr = "10.0.0.0/16"
  vpc2_cidr = "10.1.0.0/16"
}

# =========================
# Amazon Linux AMI
# =========================

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# =========================
# Bastion Host - VPC1
# =========================

module "bastion" {
  source = "./modules/ec2"

  name = "vpc1-bastion"

  vpc_id = module.vpc1.vpc_id

  subnet_id = module.vpc1.public_subnet_ids[0]

  ami_id = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

  key_name = "key.pem"

  ssh_cidr = [
    "0.0.0.0/0"
  ]
}

# =========================
# Private EC2 - VPC2
# =========================

module "private_ec2" {
  source = "./modules/ec2"

  name = "vpc2-private-server"

  vpc_id = module.vpc2.vpc_id

  subnet_id = module.vpc2.private_subnet_ids[0]

  ami_id = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

  key_name = "key.pem"

  ssh_cidr = [
    "10.0.0.0/16"
  ]
}
