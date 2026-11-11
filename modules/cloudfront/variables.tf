variable "alb_dns_name" {
  description = "DNS name of the ALB origin"
  type        = string
}

variable "domain_name" {
  description = "Public hostname for the CloudFront distribution"
  type        = string
}

variable "certificate_domain" {
  description = "Domain name used to look up the existing ACM certificate"
  type        = string
}


variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "origin_domain_name" {
  description = "Custom DNS hostname used by CloudFront to reach the ALB"
  type        = string
}