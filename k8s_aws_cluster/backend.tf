terraform {
  backend "s3" {
    bucket = "k8s-cluster-test-ng1"  # Replace with your bucket name
    key    = "test/terraform.tfstate"
    region = "us-east-1"
  }
}
