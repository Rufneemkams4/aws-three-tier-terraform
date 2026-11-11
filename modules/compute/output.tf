
# -----------------------------------------
# Compute Module Outputs
# -----------------------------------------

output "launch_template_id" {
  description = "ID of the EC2 Launch Template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version of the EC2 Launch Template"
  value       = aws_launch_template.app.latest_version
}

output "autoscaling_group_name" {
  description = "Name of the EC2 Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_group_arn" {
  description = "ARN of the EC2 Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}
