output "welcome_msg_arn" {
  value = aws_ssm_parameter.welcome_msg.arn
}

output "scrape_interval" {
  value = aws_ssm_parameter.scrape_interval.value
}

output "grafana_admin_password_arn" {
  value = aws_secretsmanager_secret.grafana_admin_password.arn
}


