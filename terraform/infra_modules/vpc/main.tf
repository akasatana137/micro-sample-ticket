#########
# VPC
#########
## https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags                = var.tags
  public_subnet_tags  = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  # VPC Flow Logs (CloudWatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}

#########
# SG
#########
## https://github.com/terraform-aws-modules/terraform-aws-security-group
# allow ingress for port 80 & 443 from anywhere (i.e. source CIDR 0.0.0.0/0)
module "public_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = local.public_security_group_name
  description = local.public_security_group_description
  vpc_id      = module.vpc.vpc_id

  ingress_rules            = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = var.public_ingress_with_cidr_blocks

  # allow all egress
  egress_rules = ["all-all"]
  tags         = local.public_security_group_tags
}

# allow ingress only from public SG for port 80, 443, and 22
module "private_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = local.private_security_group_name
  description = local.private_security_group_description
  vpc_id      = module.vpc.vpc_id

  # define ingress source as computed security group IDs, not CIDR block
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.public_security_group.security_group_id
      description              = "Port 80 from public SG rule"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.public_security_group.security_group_id
      description              = "Port 443 from public SG rule"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  # allow ingress from within
  ingress_with_self = [
    {
      rule        = "all-all"
      description = "Self"
    }
  ]

  # allow all egress
  egress_rules = ["all-all"]
  tags         = local.private_security_group_tags
}
