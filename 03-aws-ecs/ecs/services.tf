# ==========================================
# Security Group для ECS Tasks
# ==========================================
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs-tasks-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = var.vpc_id

  # Дозволяємо HTTP для Nginx (трафік від ALB)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] 
  }

  # Дозволяємо доступ до Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Дозволяємо доступ до Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Дозволяємо контейнерам виходити в інтернет
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# Сервіс: Веб (Nginx + Exporter) з підключеним ALB
# ==========================================
resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.monitoring_cluster.id
  task_definition = aws_ecs_task_definition.web.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  # Підключаємо наш ALB
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "web"
    container_port   = 80
  }

  network_configuration {
    subnets          = [var.private_subnet_a_id, var.private_subnet_b_id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.lab_local.arn
    service {
      port_name      = "web"
      discovery_name = "web"
      client_alias {
        port     = 80
        dns_name = "web.lab.local"
      }
    }
  }
}

# ==========================================
# Сервіс: Моніторинг (Prometheus + Grafana)
# ==========================================
resource "aws_ecs_service" "monitoring_service" {
  name            = "monitoring-service"
  cluster         = aws_ecs_cluster.monitoring_cluster.id
  task_definition = aws_ecs_task_definition.monitoring.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  # ДОДАНИЙ БЛОК: Підключаємо Grafana до ALB
  load_balancer {
    target_group_arn = var.grafana_target_group_arn
    container_name   = "grafana"
    container_port   = 3000
  }

  network_configuration {
    subnets          = [var.private_subnet_a_id, var.private_subnet_b_id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_private_dns_namespace.lab_local.arn
    
    service {
      port_name      = "grafana"
      discovery_name = "grafana"
      client_alias {
        port     = 3000
        dns_name = "grafana.lab.local"
      }
    }
  }
}