
# -----------------------------------------
# RDS Module Outputs
# -----------------------------------------

output "db_endpoint" {
  description = "RDS database endpoint (hostname and port)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS database hostname without port"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS MySQL connection port"
  value       = aws_db_instance.this.port
}

output "db_instance_id" {
  description = "RDS database instance identifier"
  value       = aws_db_instance.this.identifier
}

output "db_secret_arn" {
  description = "ARN of the RDS-managed master password secret"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
