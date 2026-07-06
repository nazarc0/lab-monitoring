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

