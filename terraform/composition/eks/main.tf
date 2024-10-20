#################
# VPC
#################
module "vpc" {
  source = "../../infra_modules/vpc"

  name                 = local.vpc_name
  cidr                 = var.cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  public_ingress_with_cidr_blocks = var.public_ingress_with_cidr_blocks

  env      = var.env
  app_name = var.app_name
  tags     = local.vpc_tags
  region   = var.region
}
