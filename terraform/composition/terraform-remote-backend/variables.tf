########################################
# Variables
########################################

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

########################################
## Terraform State S3 Bucket
########################################
variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state."
  type        = string
}

## s3 bucket public access block ##
variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = string
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = string
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = string
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = string
}

########################################
## DynamoDB
########################################
variable "billing_mode" {
  description = "Controls how you are billed for read/write throughput and how you manage capacity. The valid values are PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "The number of read units for this table."
  type        = string
}

variable "write_capacity" {
  description = "The number of write units for this table."
  type        = string
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type        = string
}

variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
  default     = []
}
