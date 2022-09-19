# BACKEND CODEPIPELINE
resource "aws_codepipeline" "backend_pipeline" {
  name     = "${local.stack_name}-backend-pipeline"
  role_arn = aws_iam_role.backend_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
    region = "ap-southeast-1"
  }

  artifact_store {
    location = aws_s3_bucket.eu_codepipeline_bucket.bucket
    type     = "S3"
    region = "eu-central-1"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName       = "backend"
        BranchName           = var.default_backend_branch
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "BuildAndTest"

    action {
      name             = "Build"
      category         = "Build"
      namespace        = "BuildVariables"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_backend.name
      }
    }
  }

  stage {
    name = "DeployTest"

    action {
      name            = "DeployTestSG"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName       = "test-sg"
        ServiceName       = "test-sg"
        DeploymentTimeout = "15"
      }
      role_arn = module.test_ecs_deploy_role.deploy_role_arn
      region   = "ap-southeast-1"
    }

    action {
      name            = "DeployTestFRT"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName       = "test-eu"
        ServiceName       = "test-eu"
        DeploymentTimeout = "15"
      }

      role_arn = module.test_ecs_deploy_role.deploy_role_arn
      region   = "eu-central-1"
    }
  }

  stage {
    name = "Approval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

    }
  }

  stage {
    name = "DeployProd"

    action {
      name            = "DeployProdSG"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName       = "prod-eu"
        ServiceName       = "prod-eu"
        DeploymentTimeout = "15"
      }
      role_arn = module.prod_ecs_deploy_role.deploy_role_arn
      region   = "ap-southeast-1"
    }

    action {
      name            = "DeployTestFRT"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName       = "prod-eu"
        ServiceName       = "prod-eu"
        DeploymentTimeout = "15"
      }

      role_arn = module.prod_ecs_deploy_role.deploy_role_arn
      region   = "eu-central-1"
    }
  }
}
