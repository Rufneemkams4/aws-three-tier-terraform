variable "vpc_cidr" {
  description = "Base CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to deploy across"
  type        = number
  default     = 2
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "single_nat_gateway" {
  description = "If true, deploy a single NAT Gateway shared across all private subnets to save costs. If false, deploy 1 NAT Gateway per AZ for high availability."
  type        = bool
  default     = true
}