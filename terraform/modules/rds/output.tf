output "db_instance_id" {
  value       = aws_db_instance.postgres.id
  description = "RDS instance ID"
}

output "db_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS instance endpoint"
  sensitive   = true
}

output "db_address" {
  value       = aws_db_instance.postgres.address
  description = "RDS instance address"
}

output "db_port" {
  value       = aws_db_instance.postgres.port
  description = "RDS instance port"
}

output "db_name" {
  value       = aws_db_instance.postgres.db_name
  description = "Database name"
}

output "db_password" {
  value       = local.db_password
  description = "Database master password"
  sensitive   = true
}

output "secret_arn" {
  value       = data.aws_secretsmanager_secret.rds_credentials.arn
  description = "ARN of the Secrets Manager secret"
}

output "secret_name" {
  value       = data.aws_secretsmanager_secret.rds_credentials.name
  description = "Name of the Secrets Manager secret"
}

