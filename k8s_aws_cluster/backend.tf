terraform {
  backend "s3" {
    bucket = "k8s-cluster-test-ng"  # Replace with your bucket name
    key    = "test/terraform.tfstate"
    region = "eu-west-2"
  }
}
