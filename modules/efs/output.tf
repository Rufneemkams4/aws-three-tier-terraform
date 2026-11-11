
# -----------------------------------------
# EFS Module Outputs
# -----------------------------------------

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "efs_dns_name" {
  description = "Regional DNS name of the EFS file system"
  value       = aws_efs_file_system.this.dns_name
}

output "efs_security_group_id" {
  description = "Security group ID assigned to EFS mount targets"
  value       = aws_security_group.efs.id
}

output "efs_mount_target_ids" {
  description = "IDs of the EFS mount targets"
  value       = aws_efs_mount_target.this[*].id
}
