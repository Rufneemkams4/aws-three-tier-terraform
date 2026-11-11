
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group"
  type        = string
}

variable "db_instance_id" {
  description = "RDS database instance identifier"
  type        = string
}

variable "alert_email" {
  description = "Email address for monitoring notifications"
  type        = string
}
