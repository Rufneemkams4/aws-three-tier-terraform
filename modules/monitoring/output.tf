
# -----------------------------------------
# Monitoring Module Outputs
# -----------------------------------------

output "sns_topic_arn" {
  description = "ARN of the SNS monitoring alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "alb_alarm_name" {
  description = "Name of the ALB unhealthy targets alarm"
  value       = aws_cloudwatch_metric_alarm.alb_unhealthy_targets.alarm_name
}

output "rds_alarm_name" {
  description = "Name of the RDS high CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.rds_high_cpu.alarm_name
}
