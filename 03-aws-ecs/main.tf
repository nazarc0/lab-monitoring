provider "aws" {
  region = "eu-central-1"
}

module "ecr" {
  source = "./ecr"
}

module "network" {
  source = "./network"
}

module "env" {
  source = "./env"
    slack = var.slack
}

module "ecs" {
  source = "./ecs"
    vpc_id = module.network.vpc_id
    private_subnet_a_id = module.network.private_subnet_a_id
    private_subnet_b_id = module.network.private_subnet_b_id
    vpc_cidr_block = module.network.cidrs
    web_ecr_url = module.ecr.web_ecr_url
    msg_arn = module.env.welcome_msg_arn
    welcome_msg_arn = module.env.welcome_msg_arn
    prometheus_ecr_url = module.ecr.prometheus_url    
    grafana_admin_password_arn = module.env.grafana_admin_password_arn
    alb_target_group_arn = module.network.alb_target_group_arn

}

