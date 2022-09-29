resource "aws_cloudwatch_log_group" "backend_ecs" {
  name              = "${var.stack_name}-backend-ecs"
  retention_in_days = 90
}