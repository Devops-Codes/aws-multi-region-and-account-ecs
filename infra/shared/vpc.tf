locals {
  aws_region_azs    = formatlist("${var.region}%s", ["a", "b", "c"])
  aws_eu_region_azs = formatlist("${var.eu_region}%s", ["a", "b", "c"])
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = local.stack_name
  cidr = var.vpc_cidr

  azs             = local.aws_region_azs
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 0), cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 8, 3), cidrsubnet(var.vpc_cidr, 8, 4), cidrsubnet(var.vpc_cidr, 8, 5)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "vpc_eu" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  providers = {
    aws = aws.eu-central-1
  }

  name = local.stack_name
  cidr = var.vpc_cidr_eu

  azs             = local.aws_eu_region_azs
  private_subnets = [cidrsubnet(var.vpc_cidr_eu, 8, 0), cidrsubnet(var.vpc_cidr_eu, 8, 1), cidrsubnet(var.vpc_cidr_eu, 8, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr_eu, 8, 3), cidrsubnet(var.vpc_cidr_eu, 8, 4), cidrsubnet(var.vpc_cidr_eu, 8, 5)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
}