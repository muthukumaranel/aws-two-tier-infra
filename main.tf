module "vpc" {
  source        = "./vpc"
  vpc_cidr      = var.vpc_cidr
  public_cidrs  = var.public_cidrs
  private_cidrs = var.private_cidrs
}