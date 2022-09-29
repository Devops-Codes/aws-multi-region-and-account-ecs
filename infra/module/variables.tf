variable "region" {
  type        = string
  description = "AWS region for resoruces"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "stack_name" {
  type        = string
  description = "Preffix for resoruces"
}

variable "domain" {
  type        = string
  description = "Domain for ALB"
}

variable "r53_continent" {
  type        = string
  description = "Continent for Geolaction Route 53 record"
}

variable "r53_zone_id" {
  type        = string
  description = "Continent for Geolaction Route 53 record"
}

variable "vpc_id" {
  type        = string
  description = "ID of shared VPC"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "ID's of private subnets from shared VPC"
}

variable "public_subnet_ids" {
  type        = list(any)
  description = "ID's of public subnets from shared VPC"
}

variable "ecr_repository" {
  type        = string
  description = "Name of ECR repository for backend"
}

variable "app_port" {
  type        = string
  default     = 80
  description = "Port used in backend app"
}

variable "app_cpu" {
  type        = string
  default     = 256
  description = "CPU defined in ECS Task & Container"
}

variable "app_mem" {
  type        = string
  default     = 512
  description = "RAM defined in ECS Task & Container"
}