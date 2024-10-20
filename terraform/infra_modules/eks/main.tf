###############
## Key Pair
###############
## https://github.com/terraform-aws-modules/terraform-aws-key-pair
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = local.key_pair_name
  public_key = local.public_key
}

###############
## EKS
###############
## https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"

  create          = var.create_eks
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  self_managed_node_groups = var.self_managed_node_groups
  eks_managed_node_groups  = var.eks_managed_node_groups
  node_security_group_id   = var.node_security_group_id

  # k8s secret encryption using AWS KMS
  cluster_encryption_config = {
    provider_key_arn = module.k8s_secret_kms_key.key_arn
    resources        = ["secrets"]
  }

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  ### note
  # enable access to api endpoint from this account user
  enable_cluster_creator_admin_permissions = true

  tags = var.tags
}

# todo: moduleから作成できないか確認
# 自作のresource modulesを作成した方が良いかも
resource "aws_eks_access_policy_association" "example" {
  cluster_name  = module.eks_cluster.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/k8s"

  access_scope {
    type = "cluster"
  }
}

###############
## EKS for RBAC
###############
# default moduleの都合上、余分にinitializeする必要あり
# 自作のresource modulesを作成した方が良いかも
module "eks_rbac" {
  source = "terraform-aws-modules/eks/aws//modules/aws-auth"

  create_aws_auth_configmap = var.create_aws_auth_configmap
  aws_auth_roles            = var.aws_auth_roles
  aws_auth_users = [
    {
      userarn  = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/k8s"]
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

#############
## KMS for k8s secret
#############
module "k8s_secret_kms_key" {
  source = "terraform-aws-modules/kms/aws"

  aliases                 = local.k8s_secret_kms_key_aliases
  description             = local.k8s_secret_kms_key_description
  deletion_window_in_days = local.k8s_secret_kms_key_deletion_window_in_days
  enable_key_rotation     = true

  key_administrators = local.key_administrators
  key_users          = local.key_users
  key_service_users  = local.key_service_users

  tags = local.k8s_secret_kms_key_tags
}
