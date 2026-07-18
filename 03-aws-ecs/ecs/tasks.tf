resource "aws_ecs_task_definition" "web" {
  family                   = "lab-monitoring-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "web"
      image = "${var.web_ecr_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "WELCOME_MSG"
          valueFrom = var.welcome_msg_arn 
        }
      ]
      #logConfiguration = {
       # logDriver = "awslogs"
      #  options = {
      #    "awslogs-group"         = var.web_log_group_name
      #    "awslogs-region"        = "eu-central-1"
       #   "awslogs-stream-prefix" = "web"
        #}
      #}
    },
    {
      name      = "web-exporter"
      image     = "nginx/nginx-prometheus-exporter:latest"
      essential = true
      command = ["-nginx.scrape-uri=http://localhost:80/stub_status"]
      
      portMappings = [
        {
          containerPort = 9113
          hostPort      = 9113
          protocol      = "tcp"
        }
      ]
      
      #logConfiguration = {
      #  logDriver = "awslogs"
      #  options = {
      #    "awslogs-group"         = var.web_log_group_name
      #    "awslogs-region"        = "eu-central-1"
      #    "awslogs-stream-prefix" = "web-exporter"
      #  }
      #}
    }
  ])
}







resource "aws_ecs_task_definition" "monitoring" {
  family                   = "lab-monitoring-stack"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"   # Моніторинг потребує трохи більше ресурсів
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  # 1. Створюємо логічний том на основі твого EFS
  volume {
    name = "prometheus-storage"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs_for_ecs.id
      transit_encryption = "ENABLED"
    }
  }

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "${var.prometheus_ecr_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        }
      ]

      # 2. Підключаємо наш том всередину контейнера Прометея
      mountPoints = [
        {
          sourceVolume  = "prometheus-storage"
          containerPath = "/prometheus"
          readOnly      = false
        }
      ]

      # Логи поки що також вимкнені, щоб не вимагати зайвих змінних
      #logConfiguration = { ... }
    },
    {
      name      = "grafana"
      image     = "grafana/grafana:latest" 
      essential = true
      
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      # 3. Передаємо ARN пароля з твого AWS Secrets Manager у Графану
      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = var.grafana_admin_password_arn
        }
      ]
    }
  ])
}