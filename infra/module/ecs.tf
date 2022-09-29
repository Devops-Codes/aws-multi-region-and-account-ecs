resource "aws_ecs_cluster" "backend" {
  name = "${var.stack_name}-backend-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "backend" {
  name            = "${var.stack_name}-backend-ecs-service"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_backend.arn
    container_name   = "backend"
    container_port   = var.app_port
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.backend_ecs.id]
  }

}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.stack_name}-backend-ecs-task-def"
  execution_role_arn       = aws_iam_role.backend_task_execution.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.app_cpu
  memory                   = var.app_mem
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "backend",
    "image": "${var.ecr_repository}:${var.environment}",
    "cpu": ${var.app_cpu},
    "memory": ${var.app_mem},
    "essential": true,
    "environment": [
      {"name": "ACCOUNT_ID", "value": "${data.aws_caller_identity.current.account_id}"},
      {"name": "AWS_REGION", "value": "${var.region}"},
      {"name": "FLASK_APP", "value": "hello.py"}
    ],
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.backend_ecs.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "backend"
      }
    }
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}