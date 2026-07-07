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
}

