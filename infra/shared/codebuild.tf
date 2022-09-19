# BACKEND CODEBUILD
resource "aws_codebuild_project" "build_backend" {
  name          = "${local.stack_name}-backend-build"
  description   = "${local.stack_name}-backend-build"
  build_timeout = "60"
  service_role  = aws_iam_role.backend_codebuild.arn

  artifacts {
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    privileged_mode             = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECR_API_URL"
      value = aws_ecr_repository.backend.repository_url
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.backend_build.name
    }

  }

  vpc_config {
    vpc_id = module.vpc.vpc_id

    subnets = module.vpc.private_subnets

    security_group_ids = [module.vpc.default_security_group_id]
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "codebuild/build-backend.yml"
    git_clone_depth = 0
  }
}