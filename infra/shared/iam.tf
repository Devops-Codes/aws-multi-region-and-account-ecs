# IAM Role for Backend Pipeline
resource "aws_iam_role" "backend_codepipeline" {
  name = substr("${local.stack_name}-backend-codepipeline-role", 0, 64)
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "backend_codepipeline_policy" {
  name = "${local.stack_name}-backend-codepipeline-policy"
  role = aws_iam_role.backend_codepipeline.id

  policy = data.aws_iam_policy_document.codepipeline.json
}

data "aws_iam_policy_document" "codepipeline" {

  statement {
    sid    = "CodePipelineStartCodeBuild"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodePipelineAccessArtifactS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}",
      "${aws_s3_bucket.codepipeline_bucket.arn}/*",
      "${aws_s3_bucket.eu_codepipeline_bucket.arn}",
      "${aws_s3_bucket.eu_codepipeline_bucket.arn}/*",
    ]
  }

  statement {
    sid    = "CodePipelineSTSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CodePipelineAccessCodeCommit"
    effect = "Allow"
    resources = [
      aws_codecommit_repository.backend.arn,
    ]
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:UploadArchive",
      "codecommit:BatchGet*",
      "codecommit:Get*"
    ]
  }
  statement {
    sid    = "CodePipelineKMSAccess"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.s3_artifacts.arn,
      aws_kms_key.eu_s3_artifacts.arn
    ]
  }

    statement {
    sid    = "CodePipelineECSAccess"
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = ["*"
    ]
  }
}

# IAM Role to trigger CodePipeline
resource "aws_iam_role" "codepipeline_trigger" {
  name               = "${local.stack_name}-codepipeline-trigger"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_trigger_assume.json
}

data "aws_iam_policy_document" "codepipeline_trigger_assume" {
  statement {
    sid     = "AssumeEvents"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codepipeline_trigger_policy" {
  name = "${local.stack_name}-codepipeline-trigger"
  role = aws_iam_role.codepipeline_trigger.id

  policy = data.aws_iam_policy_document.codepipeline_trigger_policy.json
}

data "aws_iam_policy_document" "codepipeline_trigger_policy" {
  statement {
    sid    = "TriggerPipeline"
    effect = "Allow"
    resources = [
      aws_codepipeline.backend_pipeline.arn,
    ]
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
  }
}

# IAM Role for Backend Codebuild
resource "aws_iam_role" "backend_codebuild" {
  name = substr("${local.stack_name}-backend-codebuild-role", 0, 64)
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "backend_codebuild" {
  role = aws_iam_role.backend_codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${module.vpc.private_subnets[0]}",
            "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${module.vpc.private_subnets[1]}",
            "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${module.vpc.private_subnets[2]}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*",
                "${aws_s3_bucket.eu_codepipeline_bucket.arn}",
        "${aws_s3_bucket.eu_codepipeline_bucket.arn}/*"
      ]
    },
          {
      "Effect": "Allow",
      "Action": [
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:GetDownloadUrlForLayer",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
      ],
      "Resource": [
            "${aws_ecr_repository.backend.arn}"
      ]
    },
            {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
                    {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
  ]
}
POLICY
}

# Roles on Test/Prod Accounts to Deploy ECS
module "test_ecs_deploy_role" {
  source = "./modules/environment"
  providers = {
    aws = aws.test
  }
  stack_name     = local.stack_name
  shared_account = data.aws_caller_identity.current.account_id
  env_account    = var.test_account_id
}

module "prod_ecs_deploy_role" {
  source = "./modules/environment"
  providers = {
    aws = aws.prod
  }
  stack_name     = local.stack_name
  shared_account = data.aws_caller_identity.current.account_id
  env_account    = var.prod_account_id
}
