# VPC for EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "eks-demo-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = []

  enable_nat_gateway = false
}

# EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0"

  cluster_name    = "demo-eks-cluster"
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access = true
}

# Create a managed node group separately
module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.0"

  cluster_name = module.eks.cluster_name
  cluster_arn  = module.eks.cluster_arn

  name = "demo-nodes"

  instance_types = ["t3.medium"]

  desired_size = 2
  min_size     = 2
  max_size     = 2

  subnet_ids = module.vpc.public_subnets
}


output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
