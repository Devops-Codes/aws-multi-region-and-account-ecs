locals {
  stack_name = "${var.project}-${var.environment}-${var.region}"
}

terraform {
  backend "s3" {
    bucket         = "aws-cicd-infrastructure"
    key            = "infrastructure/shared/ap-southeast-1/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "aws-cicd-infrastructure-tf-locks"
  }
}