resource "aws_cloudwatch_log_group" "backend_build" {
  name              = "${local.stack_name}-backend-build"
  retention_in_days = 90
}