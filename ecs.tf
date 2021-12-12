resource "aws_cloudwatch_log_group" "minecraft" {
  name              = "/ecs/${var.aws-ecs-task-name}"
  retention_in_days = 1
}

resource "aws_ecs_cluster" "minecraft" {
  name = "minecraft"
}

resource "aws_ecs_task_definition" "minecraft-on-ecs-task" {
  cpu                = 1024
  execution_role_arn = aws_iam_role.minecraft-on-ecs-task-execution-role.arn
  family             = var.aws-ecs-task-name
  memory             = 2048
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  task_role_arn = aws_iam_role.minecraft-on-ecs-task-execution-role.arn

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.minecraft-data.id
      root_directory     = "/"
      transit_encryption = "DISABLED"

      authorization_config {
        iam = "DISABLED"
      }
    }
  }

  container_definitions = jsonencode(
    [
      {
        command    = []
        cpu        = 1024
        entryPoint = []
        environment = [
          {
            name  = "EULA"
            value = "TRUE"
          },
          {
            name  = "TYPE"
            value = "PAPER"
          },
        ]
        essential = true
        image     = "itzg/minecraft-server:latest"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${var.aws-ecs-task-name}"
            awslogs-region        = var.aws-region
            awslogs-stream-prefix = "minecraft"
          }
        }
        memory            = 2048
        mountPoints = [
          {
            containerPath = "/data"
            sourceVolume  = "data"
          },
        ]
        name = "minecraft"
        portMappings = [
          {
            containerPort = 25565
            hostPort      = 25565
            protocol      = "tcp"
          },
        ]
      },
    ]
  )

  tags = {
    Name = "minecraft-on-ecs"
  }
}

resource "aws_ecs_service" "minecraft-on-ecs-service" {
  name                               = "minecraft-service"
  cluster                            = aws_ecs_cluster.minecraft.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  scheduling_strategy                = "REPLICA"
  task_definition                    = "${var.aws-ecs-task-name}:${aws_ecs_task_definition.minecraft-on-ecs-task.revision}"

  deployment_circuit_breaker {
    enable   = true
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = "minecraft"
    container_port   = 25565
    target_group_arn = aws_lb_target_group.minecraft-ecs-target.arn
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs-minecraft.id,
    ]
    subnets = [
      aws_subnet.ecs-minecraft.id,
    ]
  }

  timeouts {}

  tags = {
    "Name" = "minecraft-on-ecs"
  }
}