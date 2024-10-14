locals {
  tags = {
    Region      = var.region
    Application = var.application_name
  }
}

data "aws_caller_identity" "current" {}
