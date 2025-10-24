variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "demo-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  default     = "1.31"
}