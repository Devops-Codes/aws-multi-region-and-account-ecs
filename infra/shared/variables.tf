variable "project" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "region" {
  type        = string
  description = "Name of the AWS Region"
}

variable "eu_region" {
  type        = string
  description = "Name of the AWS Region"
}

variable "repository_name" {
  type        = string
  description = "Name of repository created in CodeCommit"
}

variable "default_backend_branch" {
  type        = string
  description = "Name of default branch for backend app"
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_cidr_eu" {
  type = string
}

variable "shared_ou_arn" {
  type = string
}

variable "test_account_id" {
  type = string
}

variable "prod_account_id" {
  type = string
}