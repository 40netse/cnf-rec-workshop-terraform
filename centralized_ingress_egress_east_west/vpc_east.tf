
#
# east VPC
#
module "vpc-east" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-east-vpc"
  vpc_cidr                   = var.vpc_cidr_east

}

module "vpc-igw-east" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-east-igw"
  vpc_id                     = module.vpc-east.vpc_id
}

resource "aws_eip" "nat-gateway-east-az1" {
  vpc = true
}

resource "aws_eip" "nat-gateway-east-az2" {
  vpc = true
}

resource "aws_nat_gateway" "vpc-east-az1" {
  allocation_id     = aws_eip.nat-gateway-east-az1.id
  subnet_id         = module.subnet-east-public-az1.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east-az1"
  }
}

resource "aws_nat_gateway" "vpc-east-az2" {
  allocation_id     = aws_eip.nat-gateway-east-az2.id
  subnet_id         = module.subnet-east-public-az2.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-east-az2"
  }
}

module "subnet-east-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-east-public-az1-subnet"

  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_east_public_az1
}
module "subnet-east-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-east-public-az2-subnet"

  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = var.vpc_cidr_east_public_az2
}


module "subnet-east-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-east-private-az1-subnet"

  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_east_private_az1
}
module "subnet-east-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-east-private-az2-subnet"

  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = var.vpc_cidr_east_private_az2
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_east" {
  default_route_table_id = module.vpc-east.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc east (unused)"
  }
}

module "route-table-east-public-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-east-public-rt-az1"

  vpc_id                     = module.vpc-east.vpc_id
}

module "route-table-association-east-public-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-east-public-az1.id
  route_table_id             = module.route-table-east-public-az1.id
}

resource "aws_route" "default-route-east-public-az1" {
  route_table_id         = module.route-table-east-public-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-east.igw_id
}

module "route-table-east-public-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-east-public-rt-az2"

  vpc_id                     = module.vpc-east.vpc_id
}

module "route-table-association-east-public-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-east-public-az2.id
  route_table_id             = module.route-table-east-public-az2.id
}

resource "aws_route" "public-default-route-east-az2" {
  route_table_id         = module.route-table-east-public-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-east.igw_id
}

module "route-table-east-private-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-east-private-rt-az1"

  vpc_id                     = module.vpc-east.vpc_id
}

module "route-table-association-east-private-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-east-private-az1.id
  route_table_id             = module.route-table-east-private-az1.id
}

resource "aws_route" "default-route-east-private-az1" {
  route_table_id         = module.route-table-east-private-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.vpc-east-az1.id
}

module "route-table-east-private-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-east-private-rt-az2"

  vpc_id                     = module.vpc-east.vpc_id
}

module "route-table-association-east-private-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-east-private-az2.id
  route_table_id             = module.route-table-east-private-az2.id
}

resource "aws_route" "default-route-east-private-az2" {
  route_table_id         = module.route-table-east-private-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-east-az2.id
}
