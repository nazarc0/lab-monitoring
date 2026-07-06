resource "aws_service_discovery_private_dns_namespace" "lab_local" {
  name        = "lab.local"
  description = "DNS namespace"
  vpc         = var.vpc_id 
}