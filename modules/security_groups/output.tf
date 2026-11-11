output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "ID of the ALB Security Group"
}

output "app_security_group_id" {
  value       = aws_security_group.app.id
  description = "ID of the App Tier Security Group"
}

output "db_security_group_id" {
  value       = aws_security_group.db.id
  description = "ID of the Database Tier Security Group"
}