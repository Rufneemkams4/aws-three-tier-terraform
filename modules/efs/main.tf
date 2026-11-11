
# -----------------------------------------
# Amazon EFS File System
# -----------------------------------------

resource "aws_efs_file_system" "this" {
  creation_token = "${var.environment}-utc-portal-efs"

  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  tags = {
    Name        = "${var.environment}-utc-portal-efs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# -----------------------------------------
# EFS Security Group
# -----------------------------------------

resource "aws_security_group" "efs" {
  name_prefix = "${var.environment}-utc-efs-"
  description = "Allow NFS access from EC2 application instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from application tier"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress = []


  tags = {
    Name        = "${var.environment}-utc-efs-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# -----------------------------------------
# EFS Mount Targets
# -----------------------------------------

resource "aws_efs_mount_target" "this" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}
