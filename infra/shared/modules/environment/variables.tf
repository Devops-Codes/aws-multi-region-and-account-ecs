variable "stack_name" {
  type        = string
  description = "Stack name passed from calling TF module"
}

variable "shared_account" {
  type        = string
  description = "ID of AWS account where CI/CD is configured"
}

variable "env_account" {
  type        = string
  description = "ID of AWS account where IAM role will be created"
}