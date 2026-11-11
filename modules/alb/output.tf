output "alb_arn" {
  value       = aws_lb.this.arn
  description = "ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_zone_id" {
  value       = aws_lb.this.zone_id
  description = "Canonical Hosted Zone ID of the ALB (for Route 53 Alias record)"
}

output "target_group_arn" {
  value       = aws_lb_target_group.app.arn
  description = "ARN of the Target Group to attach EC2 Auto Scaling Group to"
}


# -----------------------------------------
# CloudWatch Monitoring Outputs
# -----------------------------------------

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group"
  value       = aws_lb_target_group.app.arn_suffix
}
