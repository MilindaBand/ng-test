# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = local.vpc_cidr

  azs            = local.azs
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = {
    Environment = "demo"
  }
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  cluster_enabled_log_types              = []
  create_cloudwatch_log_group            = false
  cluster_encryption_config              = {}
  attach_cluster_encryption_policy       = false
  create_kms_key                         = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    demo = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "demo"
  }
}

# outputs.tf
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}"
}