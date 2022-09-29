locals {
  stack_name    = "${var.project}-${var.environment}"
  as_stack_name = "${local.stack_name}-${var.as_region}"
  eu_stack_name = "${local.stack_name}-${var.eu_region}"
}

terraform {
  backend "s3" {
    bucket         = "aws-cicd-infrastructure"
    key            = "infrastructure/test/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "aws-cicd-infrastructure-tf-locks"
  }
}