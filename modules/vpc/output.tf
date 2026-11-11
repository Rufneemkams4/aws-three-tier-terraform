output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of public subnet IDs for ALB"
}

output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "List of private subnet IDs for EC2 App tier"
}

output "private_db_subnet_ids" {
  value       = aws_subnet.private_db[*].id
  description = "List of isolated subnet IDs for RDS tier"
}

output "db_subnet_group_name" {
  value       = aws_db_subnet_group.this.name
  description = "Name of the DB subnet group for RDS"
}