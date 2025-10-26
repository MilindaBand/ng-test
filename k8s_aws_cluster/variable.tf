variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "demo-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  default     = "1.34"
}

variable "additional_iam_users" {
  description = "List of IAM users to grant cluster admin access"
  type        = list(string)
  default     = ["milinda-test"]
}