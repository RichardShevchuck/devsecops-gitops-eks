# Root module — wires vpc/eks/iam modules together

module "vpc" {
  source = "./modules/vpc"

  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  environment         = var.environment
  subnet_cidr_public  = var.subnet_cidr_public
  subnet_cidr_private = var.subnet_cidr_private
  availability_zones  = var.availability_zones
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  role_arn           = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
}
