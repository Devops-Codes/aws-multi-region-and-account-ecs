terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.31.0"
    }
  }
}

# Configure the AWS Providers
provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

provider "aws" {
  alias  = "test"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::050685593048:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "prod"
  region = "ap-southeast-1"

  assume_role {
    role_arn = "arn:aws:iam::375257297762:role/OrganizationAccountAccessRole"
  }
}