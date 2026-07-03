# 1. Створюємо спільний кластер
resource "aws_ecs_cluster" "main" {
  name = "lab-cluster"
}

# 2. Service Discovery (Cloud Map) для стабільних DNS-імен
resource "aws_service_discovery_http_namespace" "lab_local" {
  name        = "lab.local"
  description = "Internal DNS namespace for Service Connect"
}

# 3. Security Group для EFS (дозволяємо доступ тільки з приватних підмереж)
resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group"
  vpc_id      = aws_vpc.main.id # Посилання на твій VPC

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24"] # CIDR твоїх приватних сабнетів
  }
}

# 4. Створюємо мережевий диск EFS
resource "aws_efs_file_system" "monitoring_data" {
  creation_token = "monitoring-data-vol"
  tags = { Name = "Prometheus-Grafana-Data" }
}

# 5. Точки монтування EFS у приватних підмережах
resource "aws_efs_mount_target" "private_a" {
  file_system_id  = aws_efs_file_system.monitoring_data.id
  subnet_id       = aws_subnet.private_a.id # Посилання на subnet A
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "private_b" {
  file_system_id  = aws_efs_file_system.monitoring_data.id
  subnet_id       = aws_subnet.private_b.id # Посилання на subnet B
  security_groups = [aws_security_group.efs_sg.id]
}