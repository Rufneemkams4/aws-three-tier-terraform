variable "vpc_id" {
  description = "VPC ID where target groups and ALB are deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for placing the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "domain_name" {
  description = "Domain name to look up the ACM Certificate (e.g., example.com or *.example.com)"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "app_port" {
  description = "Port on which backend EC2 app instances receive traffic"
  type        = number
  default     = 8080
}