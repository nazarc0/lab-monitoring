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