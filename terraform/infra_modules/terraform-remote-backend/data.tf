locals {
  region_tag = {
    "ap-northeast-1" = "apne1"
  }

  ###################
  ## S3 Bucket
  ###################
  bucket_name = "s3-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-terraform-backend-${random_integer.digits.result}"
  acl         = "private"
  tags = merge(
    var.tags,
    tomap({
      "Name" = local.bucket_name
    })
  )

  versioning = {
    enabled = var.versioning_enabled
  }
  logging        = {}
  lifecycle_rule = []
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.s3_kms_key_terraform_backend.key_arn
      }
    }
  }

  ###################
  ## Dynamodb for TF state locking
  ###################
  dynamodb_name = "dynamo-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-terraform-state-lock"

  ###################
  ## KMS Key
  ###################
  kms_key_aliases                 = ["cmk-${local.region_tag[var.region]}-${var.env}-s3-secret"]
  kms_key_description             = "KMS Key used for Terraform remote state stored in S3"
  kms_key_deletion_window_in_days = "30"

  key_administrators = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
  key_users          = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
  key_service_users  = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]

  kms_key_tags = merge(
    var.tags,
    tomap({
      "Name" = local.kms_key_aliases[0]
    })
  )
}

data "aws_caller_identity" "this" {}

# S3 Bucket Policy
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}
