resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/practice-app"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "cluster" {
  name = "practice-cluster"
  tags = { Project = "ecs-practice" }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_ecr_image" "latest" {
  repository_name = var.ecr_repo_name
  most_recent     = true
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_task_definition" "task" {
  family                   = "practice-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "practice-app"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo_name}:latest"
      essential = true
      portMappings = [
        { containerPort = var.app_port, protocol = "tcp" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "practice"
        }
      }
    }
  ])

  tags = { Project = "ecs-practice" }
}

resource "aws_ecs_service" "service" {
  name            = "practice-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_task_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "practice-app"
    container_port   = var.app_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }

  tags = { Project = "ecs-practice" }
}
