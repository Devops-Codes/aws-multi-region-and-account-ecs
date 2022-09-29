terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-southeast-1"
    assume_role {
    role_arn = "arn:aws:iam::050685593048:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias   = "eu-central-1"
  region  = "eu-central-1"
    assume_role {
    role_arn = "arn:aws:iam::050685593048:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "root"
  region = "ap-southeast-1"
  assume_role {
    role_arn = "arn:aws:iam::088302454178:role/SharedRoute53Access"
  }
}