variable "project" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "as_region" {
  type        = string
  description = "Name of the AS AWS Region"
}

variable "eu_region" {
  type        = string
  description = "Name of the EU AWS Region"
}

variable "main_domain" {
  type        = string
  description = "Domain to register NS records"
}

variable "domain" {
  type        = string
  description = "Domain for ALB"
}