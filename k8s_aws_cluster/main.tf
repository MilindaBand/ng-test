# VPC for EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "eks-demo-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = []  # not needed for this demo

  enable_nat_gateway = false
}

# EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.1"

  cluster_name = "demo-eks-cluster"
  version      = "1.28"           # updated attribute name
  subnets      = module.vpc.public_subnets
  vpc_id       = module.vpc.vpc_id

  node_groups = {
    demo_nodes = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_type = "t3.medium"
      key_name      = "my-key"  # optional
      subnet_ids    = module.vpc.public_subnets
    }
  }

  manage_aws_auth = true
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}