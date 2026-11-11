
variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private application subnet IDs for EC2 instances"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the existing ALB target group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 2
}

variable "ami_id" {
  description = "AMI ID used by the EC2 Launch Template"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}


variable "efs_file_system_id" {
  description = "ID of the EFS file system to mount on EC2 instances"
  type        = string
}
