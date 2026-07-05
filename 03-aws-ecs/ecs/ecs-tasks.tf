# IAM Роль для виконання задач (щоб контейнер міг читати секрети)
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# Політика доступу до конкретних секретів (Least Privilege)
resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "ecs_secrets_policy"
  role = aws_iam_role.ecs_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ssm:GetParameters"]
        Resource = [
          aws_ssm_parameter.welcome_msg.arn,
          aws_ssm_parameter.scrape_interval.arn
        ]
      },
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [
          aws_secretsmanager_secret.grafana_admin.arn,
          aws_secretsmanager_secret.slack_webhook.arn
        ]
      }
    ]
  })
}

# Базова політика AWS для завантаження образів з ECR та логів
resource "aws_iam_role_policy_attachment" "ecs_exec_managed" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ==========================================
# Task Definition: WEB
# ==========================================
resource "aws_ecs_task_definition" "web" {
  family                   = "web-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "nginx:latest" # Тимчасово беремо стандартний nginx
      essential = true
      portMappings = [{
        containerPort = 80
        name          = "web-port" # Обов'язково дати ім'я порту для Service Connect
      }]
      secrets = [
        {
          name      = "WELCOME_MSG"
          valueFrom = aws_ssm_parameter.welcome_msg.arn
        }
      ]
    }
  ])
}

# ==========================================
# Task Definition: MONITORING (З EFS)
# ==========================================
resource "aws_ecs_task_definition" "monitoring" {
  family                   = "monitoring-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  # Підключаємо наш EFS диск до задачі
  volume {
    name = "monitoring-storage"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.monitoring_data.id
      transit_encryption = "ENABLED"
    }
  }

  container_definitions = jsonencode([
    {
      name      = "monitoring"
      image     = "prom/prometheus:latest" # Тимчасовий плейсхолдер
      essential = true
      portMappings = [{ containerPort = 9090 }]
      
      # Вказуємо контейнеру, куди монтувати диск
      mountPoints = [
        {
          sourceVolume  = "monitoring-storage"
          containerPath = "/prometheus"
        }
      ]
      
      secrets = [
        {
          name      = "GRAFANA_PASSWORD"
          valueFrom = aws_secretsmanager_secret.grafana_admin.arn
        },
        {
          name      = "SLACK_WEBHOOK"
          valueFrom = aws_secretsmanager_secret.slack_webhook.arn
        }
      ]
    }
  ])
}