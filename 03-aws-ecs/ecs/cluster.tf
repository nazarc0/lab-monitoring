resource "aws_ecs_cluster" "monitoring_cluster" {
  name = "monitoring-cluster"

  service_connect_defaults {
    namespace = aws_service_discovery_private_dns_namespace.lab_local.arn
  }
}