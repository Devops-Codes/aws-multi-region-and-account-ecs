variable "project" {
  type        = string
  default     = "devops-codes-ecs-deploy"
  description = "Name of the project"
}

variable "environment" {
  type        = string
  default     = "shared"
  description = "Name of the environment"
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "Name of the AWS Region"
}

variable "default_backend_branch" {
  type        = string
  default     = "develop"
  description = "Name of default branch for backend app"
}

variable "vpc_cidr" {
  type    = string
  default = "10.25.0.0/16"
}
