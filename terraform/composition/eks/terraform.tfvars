#######################
# Environment setting
#######################
region       = "ap-northeast-1"
profile_name = "k8s"
env          = "prod"
app_name     = "micro-ticket"

#######################
# VPC
#######################
cidr                 = "10.1.0.0/16"
azs                  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
public_subnets       = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] # 256 IPs per subnet
private_subnets      = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
enable_dns_hostnames = "true"
enable_dns_support   = "true"
enable_nat_gateway   = "true" # need internet connection for worker nodes in private subnets to be able to join the cluster
single_nat_gateway   = "true"


## Public Security Group ##
public_ingress_with_cidr_blocks = []

#######################
# EKS
#######################
create_eks      = true
cluster_version = "1.31"

cluster_endpoint_public_access  = true
cluster_endpoint_private_access = false

create_aws_auth_configmap = true
