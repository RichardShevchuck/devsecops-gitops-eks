resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.private_subnet[*].id
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}
