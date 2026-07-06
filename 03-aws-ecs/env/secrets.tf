variable "slack" {
  description = "URL Slack Webhook"
  type        = string
  sensitive   = true
}

resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_secretsmanager_secret" "grafana_admin_password" {
  name = "/lab/grafana/admin_password"
}

resource "aws_secretsmanager_secret_version" "grafana_admin_password_val" {
  secret_id     = aws_secretsmanager_secret.grafana_admin_password.id
  secret_string = random_password.grafana_password.result
}

resource "aws_secretsmanager_secret" "slack_webhook" {
  name = "/lab/mon/slack_webhook"
}

resource "aws_secretsmanager_secret_version" "slack_webhook_val" {
  secret_id     = aws_secretsmanager_secret.slack_webhook.id
  secret_string = var.slack
}