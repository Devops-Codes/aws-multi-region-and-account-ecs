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
}

# IAM Role for Api Codebuild
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
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
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
  shared_account = "411348447134"
  env_account    = "050685593048"
}

module "prod_ecs_deploy_role" {
  source = "./modules/environment"
  providers = {
    aws = aws.prod
  }
  stack_name     = local.stack_name
  shared_account = "411348447134"
  env_account    = "375257297762"
}