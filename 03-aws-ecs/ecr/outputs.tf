output "prometheus_arn" {
  value = aws_ecr_repository.prometheus.arn
}

output "alertmanager_arn" {
  value = aws_ecr_repository.alertmanager.arn
}

output "web_arn" {
  value = aws_ecr_repository.web.arn
}



output "prometheus_url" {
  value = aws_ecr_repository.prometheus.repository_url
}

output "alertmanager_url" {
  value = aws_ecr_repository.alertmanager.repository_url
}

output "web_ecr_url" {
  value = aws_ecr_repository.web.repository_url
}