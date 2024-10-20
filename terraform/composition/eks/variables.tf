#################
# Metadata
#################

variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "region" {
  type = string
}

variable "role_name" {
  type = string
}

variable "profile_name" {
  type = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "region_tag" {
  type = map(any)

  default = {
    "ap-northeast-1" = "apne1"
  }
}

#################
# VPC
#################
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "Number of availability zones to use in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

#################
# SG
#################
## Public Security Group ##
variable "public_ingress_with_cidr_blocks" {
  type = list(any)
}
