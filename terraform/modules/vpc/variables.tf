# vpc module — input variables
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
  description = "The CIDR block for the public subnet"
  type        = list(string)
}

variable "subnet_cidr_private" {
  description = "The CIDR block for the private subnet"
  type        = list(string)
}

variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
}
