variable "alb_dns_name" {
  description = "DNS name of the ALB origin"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the CloudFront distribution and ACM lookup"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}