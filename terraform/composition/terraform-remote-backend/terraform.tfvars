########################################
# Environment setting
########################################
region       = "ap-northeast-1"
role_name    = "Admin"
profile_name = "k8s"
env          = "prod"
app_name     = "micro-ticket"

########################################
## Terraform State S3 Bucket
########################################
force_destroy      = false
versioning_enabled = true

## s3 bucket public access block ##
block_public_policy     = true
block_public_acls       = true
ignore_public_acls      = true
restrict_public_buckets = true

########################################
## DynamoDB
########################################
billing_mode   = "PROVISIONED"
read_capacity  = 5
write_capacity = 5
hash_key       = "LockID" # state locking
attributes = [
  {
    name = "LockID"
    type = "S"
  }
]
