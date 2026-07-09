resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}
