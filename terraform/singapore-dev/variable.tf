variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS Region (Singapore)"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  nullable    = false
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for VPC"
  nullable    = false
}

variable "public_subnet_ips" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  nullable    = false
}

variable "private_subnet_ips" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
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
