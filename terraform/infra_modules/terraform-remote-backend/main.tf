# S3 bucket nameのconflict回避
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer
resource "random_integer" "digits" {
  min = 1
  max = 100

  keepers = {
    listener_arn = var.app_name
  }
}

###################
## S3
###################
# https://github.com/terraform-aws-modules/terraform-aws-s3-bucket
module "s3_bucket_terraform_remote_backend" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.bucket_name
  policy        = data.aws_iam_policy_document.bucket_policy.json
  tags          = local.tags
  force_destroy = var.force_destroy

  versioning                           = local.versioning
  server_side_encryption_configuration = local.server_side_encryption_configuration

  # s3 bucket pulic access block
  block_public_policy     = var.block_public_policy
  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

###################
## Dynamodb for TF state locking
###################
# https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table
module "dynamodb_terraform_state_lock" {
  source         = "terraform-aws-modules/dynamodb-table/aws"
  name           = local.dynamodb_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  attributes     = var.attributes
  tags           = var.tags
}

###################
## KMS Key
###################
# https://github.com/terraform-aws-modules/terraform-aws-kms
module "s3_kms_key_terraform_backend" {
  source = "terraform-aws-modules/kms/aws"

  aliases                 = local.kms_key_aliases
  description             = local.kms_key_description
  deletion_window_in_days = local.kms_key_deletion_window_in_days
  tags                    = local.kms_key_tags

  # policy                  = data.aws_iam_policy_document.s3_terraform_states_kms_key_policy.json

  key_administrators = local.key_administrators
  key_users          = local.key_users
  key_service_users  = local.key_service_users

  enable_key_rotation = true
}
