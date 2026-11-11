variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "app_port" {
  description = "Port on which the backend application listens on EC2"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Port on which the database listens (e.g., 5432 for PostgreSQL, 3306 for MySQL)"
  type        = number
  default     = 5432
}