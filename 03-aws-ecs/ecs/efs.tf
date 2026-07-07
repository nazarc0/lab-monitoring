resource "aws_efs_file_system" "efs_for_ecs" {
  creation_token = "monitoring-efs"
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] 
  }
}

resource "aws_efs_mount_target" "efs_mount_target_a" {
  file_system_id  = aws_efs_file_system.efs_for_ecs.id
  subnet_id       = var.private_subnet_a_id
  security_groups = [aws_security_group.efs_sg.id]
}
resource "aws_efs_mount_target" "efs_mount_target_b" {
  file_system_id  = aws_efs_file_system.efs_for_ecs.id
  subnet_id       = var.private_subnet_b_id
  security_groups = [aws_security_group.efs_sg.id]
}