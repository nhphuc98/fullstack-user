data "aws_secretsmanager_secret" "rds_credentials" {
  name = "fullstack-user/rds/master-credentials"
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = data.aws_secretsmanager_secret.rds_credentials.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_credentials.secret_string)
  db_password    = local.db_credentials.password
}

resource "aws_db_subnet_group" "main" {
  name       = "fullstack-user-db-subnet-group"
  subnet_ids = var.db_subnets

  tags = {
    Name = "Fullstack User DB Subnet Group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "fullstack-user-postgres"
  engine         = "postgres"
  engine_version = "14"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "fullstack_user"
  username = var.db_username
  password = local.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.db_security_group_ids
  publicly_accessible    = false

  multi_az          = false
  availability_zone = var.availability_zone

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  skip_final_snapshot     = true
  
  enabled_cloudwatch_logs_exports = ["postgresql"]

  auto_minor_version_upgrade = true

  deletion_protection = false

  tags = {
    Name        = "Fullstack User PostgreSQL"
    Environment = "dev"
  }
}

