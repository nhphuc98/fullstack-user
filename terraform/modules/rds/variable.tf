variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  nullable    = false
}

variable "db_subnets" {
  type        = list(string)
  description = "List of subnet IDs for RDS"
  nullable    = false
}

variable "db_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for RDS"
  nullable    = false
}

variable "db_username" {
  type        = string
  description = "Database master username"
  nullable    = false
  sensitive   = true
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for RDS instance"
  default     = "ap-southeast-1a"
}

