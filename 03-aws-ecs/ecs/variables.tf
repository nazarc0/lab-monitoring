variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "private_subnet_a_id" {
  description = "Private Subnet A ID"
  type        = string
}
variable "private_subnet_b_id" {
  description = "Private Subnet B ID"
  type        = string
}
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
}


variable "web_ecr_url" {
  description = "URL_ECR_Web"
  type        = string
}
variable "msg_arn" {
  description = "ARN_WELCOME_MSG_SSM"
  type        = string
}


#------
variable "welcome_msg_arn" {
  description = "Welcome Message ARN"
  type        = string
}

#---

variable "prometheus_ecr_url" {
  description = "URL репозиторію ECR для Prometheus"
  type        = string
}


variable "grafana_admin_password_arn" {
  description = "ARN секрету з паролем для Grafana"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN нашої Target Group для підключення ALB до вебу"
  type        = string
}