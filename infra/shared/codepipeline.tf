# BACKEND CODEPIPELINE
resource "aws_codepipeline" "backend_pipeline" {
  name     = "${local.stack_name}-backend-pipeline"
  role_arn = aws_iam_role.backend_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
    region   = var.region
    encryption_key {
      id   = aws_kms_key.s3_artifacts.arn
      type = "KMS"
    }
  }

  artifact_store {
    location = aws_s3_bucket.eu_codepipeline_bucket.bucket
    type     = "S3"
    region   = var.eu_region
    encryption_key {
      id   = aws_kms_key.eu_s3_artifacts.arn
      type = "KMS"
    }
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
        RepositoryName       = var.repository_name
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
      name            = "DeployTestFRT"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName       = "${var.project}-test-${var.eu_region}-backend-ecs-cluster"
        ServiceName       = "${var.project}-test-${var.eu_region}-backend-ecs-service"
        DeploymentTimeout = "15"
      }

      role_arn = "arn:aws:iam::050685593048:role/doc-ecs-shared-ap-southeast-1-cicd-deploy-role"
      region   = var.eu_region
    }

    action {
      name            = "DeployTestSG"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2

      configuration = {
        ClusterName       = "${var.project}-test-${var.region}-backend-ecs-cluster"
        ServiceName       = "${var.project}-test-${var.region}-backend-ecs-service"
        DeploymentTimeout = "15"
      }
      role_arn = "arn:aws:iam::050685593048:role/doc-ecs-shared-ap-southeast-1-cicd-deploy-role"
      region   = var.region
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
      name            = "DeployProdFRT"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1

      configuration = {
        ClusterName       = "${var.project}-prod-${var.eu_region}-backend-ecs-cluster"
        ServiceName       = "${var.project}-prod-${var.eu_region}-backend-ecs-service"
        DeploymentTimeout = "15"
      }

      role_arn = "arn:aws:iam::375257297762:role/doc-ecs-shared-ap-southeast-1-cicd-deploy-role"
      region   = var.eu_region
    }

    action {
      name            = "DeployProdSG"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 2

      configuration = {
        ClusterName       = "${var.project}-prod-${var.region}-backend-ecs-cluster"
        ServiceName       = "${var.project}-prod-${var.region}-backend-ecs-service"
        DeploymentTimeout = "15"
      }
      role_arn = "arn:aws:iam::375257297762:role/doc-ecs-shared-ap-southeast-1-cicd-deploy-role"
      region   = var.region
    }
  }
}
