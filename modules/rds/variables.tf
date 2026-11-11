
variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Existing RDS subnet group name"
  type        = string
}

variable "db_security_group_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated database storage in GiB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "utcportal"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "utcadmin"
}
