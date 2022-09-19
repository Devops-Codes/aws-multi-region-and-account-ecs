output "deploy_role_arn" {
  description = "Arn of the role used by CodePipeline to deploy ECS"
  value       = aws_iam_role.ecs_deploy.arn
}