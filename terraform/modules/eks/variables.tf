variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets for the EKS cluster"
  type        = list(string)
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS nodes"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}
