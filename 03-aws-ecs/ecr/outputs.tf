output "prometheus_arn" {
  value = aws_ecr_repository.prometheus.arn
}

output "alertmanager_arn" {
  value = aws_ecr_repository.alertmanager.arn
}

output "web_arn" {
  value = aws_ecr_repository.web.arn
}