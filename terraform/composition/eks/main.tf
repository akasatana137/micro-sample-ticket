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

###############
# EKS
###############
module "eks" {
  source = "../../infra_modules/eks"

  create_eks      = var.create_eks
  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  self_managed_node_groups = local.self_managed_node_groups
  eks_managed_node_groups  = var.eks_managed_node_groups
  node_security_group_id   = var.node_security_group_id

  # note: in this case, not create bastion ec2
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  ## RBAC ##
  create_aws_auth_configmap = var.create_aws_auth_configmap
  aws_auth_roles            = local.aws_auth_roles

  ## metadata ##
  env      = var.env
  app_name = var.app_name
  tags     = local.eks_tags
  region   = var.region
}

########################################
## KMS for EKS node's EBS volume
########################################
module "eks_node_ebs_kms_key" {
  source = "terraform-aws-modules/kms/aws"

  aliases                 = local.eks_node_ebs_kms_key_aliases
  description             = local.eks_node_ebs_kms_key_description
  deletion_window_in_days = local.eks_node_ebs_kms_key_deletion_window_in_days
  policy                  = data.aws_iam_policy_document.ebs_decryption.json
  enable_key_rotation     = true

  tags = local.eks_node_ebs_kms_key_tags
}

# Create kubeconfig file
# note: only working after created eks cluster
resource "local_file" "kubeconfig" {
  content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_name     = local.cluster_name
    cluster_cert     = module.eks.cluster_certificate_authority_data
    token            = data.aws_eks_cluster_auth.eks.token
  })
  filename = "${path.module}/kubeconfig.yml"

  depends_on = [module.eks]
}
