# Prerequisities - Enabled RAM in Organization root account
# This code might have to be commented out for the initial apply
# as Terraform has problem with for_each + modules
# After VPC's are created - you can uncomment and re-run tf apply
locals {
  subnets_arns    = concat(module.vpc.private_subnet_arns, module.vpc.public_subnet_arns)
  eu_subnets_arns = concat(module.vpc_eu.private_subnet_arns, module.vpc_eu.public_subnet_arns)
}

# Share AS subnets across OU
resource "aws_ram_resource_share" "subnets" {
  name                      = "subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_association" "subnets" {
  for_each           = { for subnet in local.subnets_arns : index(local.subnets_arns, subnet) => subnet }
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.subnets.arn
}
resource "aws_ram_principal_association" "subnets" {
  principal          = var.shared_ou_arn
  resource_share_arn = aws_ram_resource_share.subnets.arn
}

# Share EU subnets across OU
resource "aws_ram_resource_share" "eu_subnets" {
  provider                  = aws.eu-central-1
  name                      = "eu-subnets"
  allow_external_principals = false
}
resource "aws_ram_resource_association" "eu_subnets" {
  for_each           = { for subnet in local.eu_subnets_arns : index(local.eu_subnets_arns, subnet) => subnet }
  provider           = aws.eu-central-1
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.eu_subnets.arn
}
resource "aws_ram_principal_association" "eu_subnets" {
  provider           = aws.eu-central-1
  principal          = var.shared_ou_arn
  resource_share_arn = aws_ram_resource_share.eu_subnets.arn
}
