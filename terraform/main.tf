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
