terraform {
  required_version = ">= 1.0"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.64"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
}
