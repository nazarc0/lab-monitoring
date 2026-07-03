# ==========================================
# 1. SSM Parameter Store (Звичайні конфігурації)
# ==========================================

# Текст для сторінки Nginx
resource "aws_ssm_parameter" "welcome_msg" {
  name  = "/lab/web/welcome_msg"
  type  = "String"
  value = "Hello from ECS"
  
  tags = { Name = "Welcome Message" }
}

# Інтервал збору метрик
resource "aws_ssm_parameter" "scrape_interval" {
  name  = "/lab/mon/scrape_interval"
  type  = "String"
  value = "15s"
  
  tags = { Name = "Scrape Interval" }
}

# ==========================================
# 2. Secrets Manager (Секрети та паролі)
# ==========================================

# Генеруємо надійний випадковий пароль для Grafana через Terraform
resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Створюємо "сейф" для пароля Grafana
resource "aws_secretsmanager_secret" "grafana_admin" {
  name                    = "/lab/grafana/admin_password"
  description             = "Grafana Admin Password"
  recovery_window_in_days = 0 # Видаляти одразу при terraform destroy (без очікування 7-30 днів)
}

# Кладемо згенерований пароль у цей "сейф"
resource "aws_secretsmanager_secret_version" "grafana_admin_val" {
  secret_id     = aws_secretsmanager_secret.grafana_admin.id
  secret_string = random_password.grafana_password.result
}

# Створюємо "сейф" для Slack Webhook
resource "aws_secretsmanager_secret" "slack_webhook" {
  name                    = "/lab/mon/slack_webhook"
  description             = "Slack Webhook for Alertmanager"
  recovery_window_in_days = 0 
}

# Кладемо фейковий URL у сейф Slack
resource "aws_secretsmanager_secret_version" "slack_webhook_val" {
  secret_id     = aws_secretsmanager_secret.slack_webhook.id
  secret_string = "placeholder-for-slack-webhook"
}

# ==========================================
# 3. Вивід згенерованого пароля в термінал (щоб ти міг зайти в Grafana)
# ==========================================
output "grafana_generated_password" {
  value       = random_password.grafana_password.result
  sensitive   = true # Приховає пароль при звичайному apply
  description = "Пароль для Grafana. Щоб побачити, введи: terraform output -raw grafana_generated_password"
}