resource "aws_ecr_repository" "backend" {
  name                 = "${local.stack_name}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.backend.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Rotate images when reach 15 images stored",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 15
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "ReadonlyAccess"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        // test
        "arn:aws:iam::${var.test_account_id}:root",
        // prod
        "arn:aws:iam::${var.prod_account_id}:root",
      ]
    }
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
    ]
  }
}

resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.backend.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}
