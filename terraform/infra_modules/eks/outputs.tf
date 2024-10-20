###############
## Key Pair
###############
output "key_pair_id" {
  description = "The key pair ID"
  value       = module.key_pair.key_pair_id
}

output "key_pair_arn" {
  description = "The key pair ARN"
  value       = module.key_pair.key_pair_arn
}

output "key_pair_name" {
  description = "The key pair name"
  value       = module.key_pair.key_pair_name
}

output "key_pair_fingerprint" {
  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716"
  value       = module.key_pair.key_pair_fingerprint
}

###############
## EKS
###############
output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.cluster_id
}

output "cluster_id" {
  description = "The id of the EKS cluster."
  value       = module.eks_cluster.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks_cluster.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks_cluster.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.eks_cluster.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks_cluster.cloudwatch_log_group_name
}

###############
## KMS Key
###############
output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = module.k8s_secret_kms_key.key_arn
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = module.k8s_secret_kms_key.key_id
}

output "key_policy" {
  description = "The IAM resource policy set on the key"
  value       = module.k8s_secret_kms_key.key_policy
}
