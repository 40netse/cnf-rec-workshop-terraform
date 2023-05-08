
locals {
    common_tags = {
    Environment = var.env
  }
}
provider "aws" {
  region     = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}


locals {
  availability_zone_1 = "${var.aws_region}${var.availability_zone_1}"
}

locals {
  availability_zone_2 = "${var.aws_region}${var.availability_zone_2}"
}
locals {
  public_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.public_subnet_index)
}
locals {
  public_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.public_subnet_index + 3)
}
locals {
  fwaas_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.fwaas_subnet_index)
}
locals {
  fwaas_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.fwaas_subnet_index + 3)
}
locals {
  private_subnet_cidr_az1 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.private_subnet_index)
}
locals {
  private_subnet_cidr_az2 = cidrsubnet(var.vpc_cidr_inspection, var.subnet_bits, var.private_subnet_index + 3)
}
locals {
  fortimanager_ip_address = cidrhost(local.private_subnet_cidr_az1, var.fortimanager_host_ip)
}

resource "random_string" "random" {
  length           = 5
  special          = false
}

#
# VPC Setups, route tables, route table associations
#

#
# Spoke VPC
#
module "vpc-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_vpc"
  vpc_name                   = "${var.cp}-${var.env}-inspection-vpc"
  vpc_cidr                   = var.vpc_cidr_inspection
}

module "vpc-igw-inspection" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_igw"
  igw_name                   = "${var.cp}-${var.env}-inspection-igw"
  vpc_id                     = module.vpc-inspection.vpc_id
}

module "igw-route-table" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-igw-rt"

  vpc_id                     = module.vpc-inspection.vpc_id
}
resource "aws_route_table_association" "b" {
  gateway_id     = module.vpc-igw-inspection.igw_id
  route_table_id = module.igw-route-table.id
}

#
# AZ 1
#
module "subnet-public-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-public-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.public_subnet_cidr_az1
}
resource aws_ec2_tag "subnet_public_tag_az1" {
  resource_id = module.subnet-public-az1.id
  key = "Workshop-area"
  value = "Public-Az1"
}

module "subnet-fwaas-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-fwaas-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.fwaas_subnet_cidr_az1
}

resource aws_ec2_tag "subnet_fwaas_tag_az1" {
  resource_id = module.subnet-fwaas-az1.id
  key = "Workshop-area"
  value = "Fwaas-Az1"
}

module "subnet-private-az1" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-private-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_1
  subnet_cidr                = local.private_subnet_cidr_az1
}
resource aws_ec2_tag "subnet_private_tag_az1" {
  resource_id = module.subnet-private-az1.id
  key = "Workshop-area"
  value = "Private-Az1"
}
module "private-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-private-rt-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "private-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-private-az1.id
  route_table_id             = module.private-route-table-az1.id
}
module "fwaas-route-table-az1" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-fwaas-rt-az1"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "fwaas-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-fwaas-az1.id
  route_table_id             = module.fwaas-route-table-az1.id
}

#
# AZ 2
#
module "subnet-public-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-public-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.public_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_public_tag_az2" {
  resource_id = module.subnet-public-az2.id
  key = "Workshop-area"
  value = "Public-Az2"
}
module "subnet-fwaas-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-fwaas-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.fwaas_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_fwaas_tag_az2" {
  resource_id = module.subnet-fwaas-az2.id
  key = "Workshop-area"
  value = "Fwaas-Az2"
}
resource aws_ec2_tag "fwaas_tag_az1" {
  resource_id = module.subnet-fwaas-az1.id
  key = "fortigatecnf_subnet_type"
  value = "endpoint"
}
resource aws_ec2_tag "fwaas_tag_az2" {
  resource_id = module.subnet-fwaas-az2.id
  key = "fortigatecnf_subnet_type"
  value = "endpoint"
}
module "subnet-private-az2" {
  source = "git::https://github.com/40netse/terraform-modules.git//aws_subnet"
  subnet_name                = "${var.cp}-${var.env}-inspection-private-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
  availability_zone          = local.availability_zone_2
  subnet_cidr                = local.private_subnet_cidr_az2
}
resource aws_ec2_tag "subnet_private_tag_az2" {
  resource_id = module.subnet-private-az2.id
  key = "Workshop-area"
  value = "Private-Az2"
}
module "public-route-table" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-public-rt"

  vpc_id                     = module.vpc-inspection.vpc_id
}

module "public_route_table_association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-public-az2.id
  route_table_id             = module.public-route-table.id
}

module "private-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-private-rt-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "private-route-table-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-private-az2.id
  route_table_id             = module.private-route-table-az2.id
}
module "fwaas-route-table-az2" {
  source  = "git::https://github.com/40netse/terraform-modules.git//aws_route_table"
  rt_name = "${var.cp}-${var.env}-inspection-fwaas-rt-az2"

  vpc_id                     = module.vpc-inspection.vpc_id
}
module "fwaas-route-table-association" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-fwaas-az2.id
  route_table_id             = module.fwaas-route-table-az2.id
}

module "public-route-table-association-az1" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-public-az1.id
  route_table_id             = module.public-route-table.id
}

module "public-route-table-association-az2" {
  source   = "git::https://github.com/40netse/terraform-modules.git//aws_route_table_association"

  subnet_ids                 = module.subnet-public-az2.id
  route_table_id             = module.public-route-table.id
}

#
# Default route table that is created with the main VPC.
#
resource "aws_default_route_table" "route_inspection" {
  default_route_table_id = module.vpc-inspection.vpc_main_route_table_id
  tags = {
    Name = "default table for vpc inspection (unused)"
  }
}

#
# Point the private route table default route to the Fortigate Private ENI
#
resource "aws_route" "public-default-route" {
  route_table_id         = module.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}
resource "aws_route" "private-az1-default-route" {
  route_table_id         = module.private-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}
resource "aws_route" "private-az2-default-route" {
  route_table_id         = module.private-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}
resource "aws_route" "fwaas-az1-default-route" {
  route_table_id         = module.fwaas-route-table-az1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}
resource "aws_route" "fwaas-az2-default-route" {
  route_table_id         = module.fwaas-route-table-az2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc-igw-inspection.igw_id
}

#
# VPC Endpoint for AWS API Calls
#
module "vpc_s3_endpoint" {
  source                     = "git::https://github.com/40netse/terraform-modules.git//aws_vpc_endpoints"

  aws_region                 = var.aws_region
  vpc_endpoint_name          = "${var.cp}-${var.env}-vpc_endpoint"
  vpc_id                     = module.vpc-inspection.vpc_id
  route_table_id             = [ module.public-route-table.id ]
}

