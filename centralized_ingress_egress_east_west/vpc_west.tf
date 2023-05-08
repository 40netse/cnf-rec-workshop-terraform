
#
# west VPC
#
module "vpc-west" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-west-vpc"
  vpc_cidr                   = var.vpc_cidr_west

}

module "vpc-igw-west" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-west-igw"
  vpc_id                     = module.vpc-west.vpc_id
}

resource "aws_eip" "nat-gateway-west-az1" {
  vpc = true
}

resource "aws_eip" "nat-gateway-west-az2" {
  vpc = true
}

resource "aws_nat_gateway" "vpc-west-az1" {
  allocation_id     = aws_eip.nat-gateway-west-az1.id
  subnet_id         = module.subnet-west-public-az1.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-west-az1"
  }
}

resource "aws_nat_gateway" "vpc-west-az2" {
  allocation_id     = aws_eip.nat-gateway-west-az2.id
  subnet_id         = module.subnet-west-public-az2.id
  tags = {
    Name = "${var.cp}-${var.env}-nat-gw-west-az2"
  }
}

module "subnet-west-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-west-public-az1-subnet"

  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west_public_az1
}
module "subnet-west-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-west-public-az2-subnet"

  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = var.vpc_cidr_west_public_az2
}


module "subnet-west-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-west-private-az1-subnet"

  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west_private_az1
}
module "subnet-west-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-west-private-az2-subnet"

  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = var.vpc_cidr_west_private_az2
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_west" {
  default_route_table_id = module.vpc-west.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc west (unused)"
  }
}

module "route-table-west-public-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-west-public-rt-az1"

  vpc_id                     = module.vpc-west.vpc_id
}

module "route-table-association-west-public-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-west-public-az1.id
  route_table_id             = module.route-table-west-public-az1.id
}

resource "aws_route" "default-route-west-public-az1" {
  route_table_id         = module.route-table-west-public-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-west.igw_id
}

module "route-table-west-public-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-west-public-rt-az2"

  vpc_id                     = module.vpc-west.vpc_id
}

module "route-table-association-west-public-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-west-public-az2.id
  route_table_id             = module.route-table-west-public-az2.id
}

resource "aws_route" "public-default-route-west-az2" {
  route_table_id         = module.route-table-west-public-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-west.igw_id
}

module "route-table-west-private-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-west-private-rt-az1"

  vpc_id                     = module.vpc-west.vpc_id
}

module "route-table-association-west-private-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-west-private-az1.id
  route_table_id             = module.route-table-west-private-az1.id
}

resource "aws_route" "default-route-west-private-az1" {
  route_table_id         = module.route-table-west-private-az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-west-az1.id
}

module "route-table-west-private-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-west-private-rt-az2"

  vpc_id                     = module.vpc-west.vpc_id
}

module "route-table-association-west-private-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-west-private-az2.id
  route_table_id             = module.route-table-west-private-az2.id
}

resource "aws_route" "default-route-west-private-az2" {
  route_table_id         = module.route-table-west-private-az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc-west-az2.id
}
