
# -----------------------------------------
# Amazon SNS Topic for Monitoring Alerts
# -----------------------------------------

resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-utc-portal-alerts"

  tags = {
    Name        = "${var.environment}-utc-portal-alerts"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# -----------------------------------------
# SNS Email Subscription
# -----------------------------------------

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}


# -----------------------------------------
# CloudWatch Alarm - ALB Unhealthy Targets
# -----------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name        = "${var.environment}-utc-alb-unhealthy-targets"
  alarm_description = "Alert when ALB has one or more unhealthy application targets"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# -----------------------------------------
# CloudWatch Alarm - No Healthy ALB Targets
# -----------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_no_healthy_targets" {
  alarm_name        = "${var.environment}-utc-alb-no-healthy-targets"
  alarm_description = "Alert when the ALB has no healthy application targets"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HealthyHostCount"

  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "breaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# -----------------------------------------
# CloudWatch Alarm - RDS CPU Utilization
# -----------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name        = "${var.environment}-utc-rds-high-cpu"
  alarm_description = "Alert when RDS CPU utilization remains above 80 percent"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"

  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  treat_missing_data = "missing"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
