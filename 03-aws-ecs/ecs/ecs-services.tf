# Security Group для задач (дозволяє трафік всередині VPC)
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "ecs-tasks-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Трафік ходить тільки всередині VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Дозвіл на вихід в інтернет через NAT
  }
}

# ==========================================
# ECS Service: WEB
# ==========================================
resource "aws_ecs_service" "web_svc" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false # Задачі сховані в приватній мережі
  }

  # Service Connect: Реєструємо web під ім'ям web.lab.local
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.lab_local.arn
    service {
      port_name      = "web-port"
      discovery_name = "web"
      client_alias {
        port     = 80
        dns_name = "web.lab.local"
      }
    }
  }
}

# ==========================================
# ECS Service: MONITORING
# ==========================================
resource "aws_ecs_service" "monitoring_svc" {
  name            = "monitoring-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.monitoring.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  # Моніторинг виступає як клієнт, якому треба знайти web.lab.local
  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.lab_local.arn
  }
}