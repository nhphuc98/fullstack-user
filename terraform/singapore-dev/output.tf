# VPC Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public Subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private Subnet IDs"
}

# Security Groups Outputs
output "public_security_group_id" {
  value       = module.security_groups.public_security_group_id
  description = "Public Security Group ID"
}

output "private_security_group_id" {
  value       = module.security_groups.private_security_group_id
  description = "Private Security Group ID"
}

output "rds_security_group_id" {
  value       = module.security_groups.rds_security_group_id
  description = "RDS Security Group ID"
}

# ECR Outputs (from AWS Console)
output "frontend_ecr_repository_url" {
  value       = data.aws_ecr_repository.frontend.repository_url
  description = "Frontend ECR Repository URL"
}

output "backend_ecr_repository_url" {
  value       = data.aws_ecr_repository.backend.repository_url
  description = "Backend ECR Repository URL"
}

# RDS Outputs
output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "RDS Endpoint"
  sensitive   = true
}

output "rds_address" {
  value       = module.rds.db_address
  description = "RDS Address"
}

# Secrets Manager Outputs
output "rds_secret_arn" {
  value       = module.rds.secret_arn
  description = "ARN of the Secrets Manager secret containing RDS credentials"
}

output "rds_secret_name" {
  value       = module.rds.secret_name
  description = "Name of the Secrets Manager secret"
}

# ALB Outputs
output "alb_dns_name" {
  value       = module.alb.alb_dns
  description = "ALB DNS Name"
}

output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ALB ARN"
}

# Application URL
output "application_url" {
  value       = "http://${module.alb.alb_dns}"
  description = "Application URL"
}

output "backend_target_group_arn" {
  value       = module.alb.backend_target_group_arn
  description = "Backend Target Group ARN"
}

output "frontend_target_group_arn" {
  value       = module.alb.frontend_target_group_arn
  description = "Frontend Target Group ARN"
}