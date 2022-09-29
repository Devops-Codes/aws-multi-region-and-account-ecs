# ECS Service Role
resource "aws_iam_role" "backend_task_execution" {
  name = "${var.stack_name}-ecs-task-execution-role"
  path = "/service-role/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "backend_task_execution" {
  name = "${var.stack_name}-ecs-task-execution-policy"
  role = aws_iam_role.backend_task_execution.id

  policy = data.aws_iam_policy_document.backend_task_ex_policy.json
}

data "aws_iam_policy_document" "backend_task_ex_policy" {
  statement {
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
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]

    effect = "Allow"
  }
}