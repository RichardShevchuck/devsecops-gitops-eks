# Root-level input variables

variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}

variable "subnet_cidr_public" {
  description = "CIDR blocks for the public subnets (one per AZ)"
  type        = list(string)
}

variable "subnet_cidr_private" {
  description = "CIDR blocks for the private subnets (one per AZ)"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across (minimum 2, required by EKS)"
  type        = list(string)
}
