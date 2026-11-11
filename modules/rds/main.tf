
# -----------------------------------------
# Amazon RDS MySQL Database
# -----------------------------------------

resource "aws_db_instance" "this" {
  identifier = "${var.environment}-utc-portal-db"

  # Database engine
  engine         = "mysql"
  engine_version = "8.4.7"

  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  # Instance configuration
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  # Database credentials
  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true

  # Network configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  port                   = 3306

  # Development availability
  multi_az = false

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  # Maintenance
  auto_minor_version_upgrade = true

  # Development deletion settings
  deletion_protection = false
  skip_final_snapshot = true

  # Monitoring
  performance_insights_enabled = false

  tags = {
    Name        = "${var.environment}-utc-portal-db"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }


  copy_tags_to_snapshot = true


}