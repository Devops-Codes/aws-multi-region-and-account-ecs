output "aws_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "aws_vpc_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "aws_vpc_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "aws_vpc_eu_id" {
  description = "The ID of the EU VPC"
  value       = module.vpc_eu.vpc_id
}

output "aws_vpc_eu_private_subnets" {
  description = "List of IDs of EU private subnets"
  value       = module.vpc_eu.private_subnets
}

output "aws_vpc_eu_public_subnets" {
  description = "List of IDs of EU public subnets"
  value       = module.vpc_eu.public_subnets
}

output "ecr_backend_url" {
  description = "URL of backend Container Registry"
  value       = aws_ecr_repository.backend.repository_url
}