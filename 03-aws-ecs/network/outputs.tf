output "vpc_id" {
  description = "VPCID"
  value = aws_vpc.main.id
}

output "private_subnet_a_id" {
  description = "Private Subnet A ID"
  value = aws_subnet.private_a.id
}

output "private_subnet_b_id" {
  description = "Private Subnet B ID"
  value = aws_subnet.private_b.id
}

output "cidrs" {
  description = "VPC CIDR"
  value = aws_vpc.main.cidr_block
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.alb_target_group.arn
}