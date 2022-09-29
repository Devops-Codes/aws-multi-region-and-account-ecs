data "terraform_remote_state" "shared_remote_state" {
  backend = "s3"

  config = {
    bucket = "aws-cicd-infrastructure"
    key    = "infrastructure/shared/ap-southeast-1/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "aws_route53_zone" "main_domain" {
  provider     = aws.root
  name         = var.main_domain
  private_zone = false
}