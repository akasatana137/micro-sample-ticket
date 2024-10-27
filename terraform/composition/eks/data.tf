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

  self_managed_node_groups = {
    worker-group-1 = {
      ami_type = "AL2_x86_64"
      # instance_type = "m3.medium" not compatiable at az(1d)
      # can create up to 29 pods
      instance_type = "m5.large"

      min_size     = 1
      max_size     = 2
      desired_size = 2

      # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2056
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            # volume_size           = 75
            # volume_type           = "gp3"
            # only valid for io1, io2, gp3
            # iops                  = 3000
            # only valid for gps
            # throughput            = 150
            encrypted             = true
            kms_key_id            = module.eks_node_ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

      tags = {
        "key"                 = "self-managed-node"
        "propagate_at_launch" = "true"
        "value"               = "true"
      }
    }
  }

  ## EBS volume encrypted
  eks_node_ebs_kms_key_aliases                 = ["alias/cmk-${var.region_tag[var.region]}-${var.env}-eks-node-ebs-volume"]
  eks_node_ebs_kms_key_description             = "Kms key used for EKS node`s EBS volume"
  eks_node_ebs_kms_key_deletion_window_in_days = 30
  eks_node_ebs_kms_key_tags = merge(
    local.eks_tags,
    tomap({
      "Name" = local.eks_node_ebs_kms_key_aliases[0]
    })
  )


  eks_tags = {
    Environment = var.env
    Application = var.app_name
  }
}

data "aws_caller_identity" "this" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth
## note: this is temporary token, so manual renewal required after expiration
data "aws_eks_cluster_auth" "eks" {
  name = local.cluster_name
}

# https://docs.aws.amazon.com/ja_jp/autoscaling/ec2/userguide/key-policy-requirements-EBS-encryption.html
data "aws_iam_policy_document" "ebs_decryption" {
  # Copy of default KMS policy that lets you manage it
  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  # Required for EKS
  statement {
    sid    = "Allow service-linked role use of the CMK"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root", # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,                                                                                                         # required for the cluster /persistentvolume-controller to create encrypted PVCs
      ]
    }

    actions = [
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

  }
}
