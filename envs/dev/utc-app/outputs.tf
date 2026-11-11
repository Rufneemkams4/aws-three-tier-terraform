
# -----------------------------------------
# UTC Student Services Portal
# Root Terraform Outputs
# -----------------------------------------

# Public application URL
output "portal_url" {
  description = "Public HTTPS URL of the UTC Student Services Portal"
  value       = "https://${var.domain_name}"
}

# CloudFront
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

# Application Load Balancer
output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

# EC2 Auto Scaling
output "autoscaling_group_name" {
  description = "EC2 Auto Scaling Group name"
  value       = module.compute.autoscaling_group_name
}

# RDS MySQL
output "rds_endpoint" {
  description = "Private RDS MySQL endpoint"
  value       = module.rds.db_endpoint
}

# Amazon EFS
output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = module.efs.efs_file_system_id
}

# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# Monitoring
output "sns_topic_arn" {
  description = "SNS topic ARN for infrastructure alerts"
  value       = module.monitoring.sns_topic_arn
}
