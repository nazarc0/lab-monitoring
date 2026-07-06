resource "aws_ssm_parameter" "welcome_msg" {
  name  = "/lab/web/welcome_msg"
  type  = "String"
  value = "Hello from ECS"
}

resource "aws_ssm_parameter" "scrape_interval" {
  name  = "/lab/mon/scrape_interval"
  type  = "String"
  value = "15s"
}