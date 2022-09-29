resource "aws_codecommit_repository" "backend" {
  repository_name = var.repository_name
  description     = "Python backend app"
  default_branch  = var.default_backend_branch
}