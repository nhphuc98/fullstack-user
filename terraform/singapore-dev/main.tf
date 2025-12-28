terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = var.region
}

# Module 1: VPC (Network)
module "vpc" {
  source             = "../modules/vpc"
  region             = var.region
  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones
  public_subnet_ips  = var.public_subnet_ips
  private_subnet_ips = var.private_subnet_ips
}

# Module 2: Security Groups
module "security_groups" {
  source = "../modules/security-groups"
  vpc_id = module.vpc.vpc_id
  region = var.region
}

data "aws_ecr_repository" "frontend" {
  name = "fullstack-user-frontend"
}

data "aws_ecr_repository" "backend" {
  name = "fullstack-user-backend"
}

# Module 3: RDS PostgreSQL Database
module "rds" {
  source                 = "../modules/rds"
  region                 = var.region
  vpc_id                 = module.vpc.vpc_id
  db_subnets             = module.vpc.private_subnet_ids
  db_security_group_ids  = [module.security_groups.rds_security_group_id]
  db_username            = var.db_username
  db_instance_class      = var.db_instance_class
  availability_zone      = var.availability_zones[0]
}

# Module 4: Application Load Balancer
module "alb" {
  source                           = "../modules/alb"
  region                           = var.region
  vpc_id                           = module.vpc.vpc_id
  load_balance_subnet_ids          = module.vpc.public_subnet_ids
  load_balance_security_group_ids  = [module.security_groups.public_security_group_id]
}

# Module 5: ECS Cluster and Services
module "ecs" {
  source                     = "../modules/ecs"
  region                     = var.region
  vpc_id                     = module.vpc.vpc_id
  ecs_subnet_ids             = module.vpc.private_subnet_ids
  ecs_security_group_ids     = [module.security_groups.private_security_group_id]
  alb_arn                    = module.alb.alb_arn
  alb_dns                    = module.alb.alb_dns
  frontend_target_group_arn  = module.alb.frontend_target_group_arn
  frontend_ecr_image_url     = data.aws_ecr_repository.frontend.repository_url
  backend_target_group_arn   = module.alb.backend_target_group_arn
  backend_ecr_image_url      = data.aws_ecr_repository.backend.repository_url
  db_endpoint                = module.rds.db_address
  db_name                    = module.rds.db_name
  db_username                = var.db_username
  db_password                = module.rds.db_password
  db_secret_arn              = module.rds.secret_arn
  
  depends_on = [module.rds]
}

