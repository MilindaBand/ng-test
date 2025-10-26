# VPC for EKS
    module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"

    name = "eks-demo-vpc"
    cidr = "10.0.0.0/16"
    map_public_ip_on_launch = true

    azs            = ["us-east-1a", "us-east-1b"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = []

    enable_nat_gateway = false
    enable_dns_hostnames = true
    enable_dns_support   = true
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

  # Add additional IAM users with admin access
  access_entries = {
    for idx, user in var.additional_iam_users : user => {
      principal_arn = "arn:aws:iam::729874396527:user/${user}"
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
#   cluster_addons = {
#     aws-ebs-csi-driver = {
#       most_recent              = true
#       service_account_role_arn = "arn:aws:iam::729874396527:role/AmazonEKS_EBS_CSI_DriverRole"
#       depends_on               = [module.eks.eks_managed_node_groups]
#     }
#   }
  eks_managed_node_groups = {
    demo-node-1 = {
      min_size     = 0
      max_size     = 0
      desired_size = 0

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        node = "node-1"
        role = "worker"
      }

      tags = {
        Name = "eks-demo-node-1"
      }
    }

    demo-node-2 = {
      min_size     = 0
      max_size     = 0
      desired_size = 0

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        node = "node-2"
        role = "worker"
      }

      tags = {
        Name = "eks-demo-node-2"
      }
    }
  }

  tags = {
    Environment = "demo"
  }
}

# resource "aws_eks_addon" "aws_ebs_csi_driver" {
#   cluster_name           = module.eks.cluster_name
#   addon_name             = "aws-ebs-csi-driver"
#   service_account_role_arn = "arn:aws:iam::729874396527:role/AmazonEKS_EBS_CSI_DriverRole"
#   resolve_conflicts_on_create = "OVERWRITE"
#   depends_on             = [module.eks.eks_managed_node_groups]
# }


# outputs.tf
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "configure_kubectl" {
  description = "Configure kubectl command"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}"
}