locals {
  tags = {
    Region      = var.region
    Application = var.app_name
  }
}

data "aws_caller_identity" "current" {}
