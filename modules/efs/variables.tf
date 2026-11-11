
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EFS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID of EC2 application instances"
  type        = string
}
