locals {
  tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }

  ##############
  ## VPC
  ##############
  vpc_name = "vpc-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  vpc_tags = merge(
    local.tags,
    tomap({
      "VPC-Name" = local.vpc_name
    })
  )

  ##############
  ## EKS
  ##############
  cluster_name = "eks-${var.region_tag[var.region]}-${var.app_name}"

  ## RBAC
  aws_auth_roles = [
    {
      role_arn = "arn:aws:iam:${data.aws_caller_identity.this.account_id}:role/Admin"
      username = "k8s_terraform_builder"
      groups   = ["system:masters"]
    }
  ]

  eks_tags = {
    Environment = var.env
    Application = var.app_name
  }
}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}
