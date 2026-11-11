variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "domain_name" {
  description = "Domain name associated with your existing ACM Certificate"
  type        = string
}

variable "hosted_zone_name" {
  type = string
}