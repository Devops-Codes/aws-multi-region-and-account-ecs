resource "aws_iam_role" "ecs_deploy" {
  name               = "${var.stack_name}-cicd-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_deploy.json
}

data "aws_iam_policy_document" "ecs_deploy" {
  statement {
    sid = "AssumeRoleFromShared"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.shared_account}:root"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ecs_deploy_policy" {
  statement {
    sid = "ECSPermissions"
    # TODO policy to be less permissive
    actions = [
      "ecs:*",
      "ecr:*"
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
    statement {
    sid = "KMSPermissions"
    # TODO policy to be less permissive
    actions = [
      "kms:*"
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
    statement {
    sid = "S3Permissions"
    # TODO policy to be less permissive
    actions = [
      "*"
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy" "ecs_role_policy" {
  name   = "${var.stack_name}-ecs-deploy"
  role   = aws_iam_role.ecs_deploy.id
  policy = data.aws_iam_policy_document.ecs_deploy_policy.json
}