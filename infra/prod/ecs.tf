module "backend" {
  source             = "../module"
  stack_name         = local.as_stack_name
  region             = var.as_region
  environment        = var.environment
  r53_continent      = "*"
  r53_zone_id        = aws_route53_zone.aws-prod.zone_id
  vpc_id             = data.terraform_remote_state.shared_remote_state.outputs.aws_vpc_id
  private_subnet_ids = data.terraform_remote_state.shared_remote_state.outputs.aws_vpc_private_subnets
  public_subnet_ids  = data.terraform_remote_state.shared_remote_state.outputs.aws_vpc_public_subnets
  domain             = var.domain
  ecr_repository     = "411348447134.dkr.ecr.ap-southeast-1.amazonaws.com/doc-ecs-shared-ap-southeast-1-backend"
  app_port = 5000
}

module "backend_eu" {
  source = "../module"
  providers = {
    aws = aws.eu-central-1
  }
  stack_name         = local.eu_stack_name
  region             = var.eu_region
  environment        = var.environment
  r53_continent      = "EU"
  r53_zone_id        = aws_route53_zone.aws-prod.zone_id
  vpc_id             = data.terraform_remote_state.shared_remote_state.outputs.aws_vpc_eu_id
  private_subnet_ids = data.terraform_remote_state.shared_remote_state.outputs.aws_vpc_eu_private_subnets
  public_subnet_ids  = data.terraform_remote_state.shared_remote_state.outputs.aws_vpc_eu_public_subnets
  domain             = var.domain
  ecr_repository     = "411348447134.dkr.ecr.ap-southeast-1.amazonaws.com/doc-ecs-shared-ap-southeast-1-backend"
app_port = 5000
}