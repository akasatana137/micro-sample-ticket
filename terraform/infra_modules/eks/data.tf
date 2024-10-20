locals {
  #############
  ## Key Pair
  #############
  key_pair_name = "eks-workers-keypair-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  public_key    = file("${path.module}/id_rsa.pub")

  #############
  ## KMS for k8s secret
  #############
  k8s_secret_kms_key_aliases                 = ["cmk-${var.region_tag[var.region]}-${var.env}-k8s-secret-dek"]
  k8s_secret_kms_key_description             = "KSM key used for encrypting k8s secret"
  k8s_secret_kms_key_deletion_window_in_days = 30

  key_administrators = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
  key_users = [
    module.eks_cluster.cluster_iam_role_arn,
    "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
  ]
  key_service_users = [module.eks_cluster.cluster_iam_role_arn]

  k8s_secret_kms_key_tags = merge(
    var.tags,
    tomap({
      "Name" = local.k8s_secret_kms_key_aliases[0]
    })
  )
}

data "aws_caller_identity" "this" {}
