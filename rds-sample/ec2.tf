module "ec2" {
  source = "./module/ec2"

  app_name       = var.name
  vpc_id         = module.network.vpc_id
  pub_subnet_ids = module.network.pub_subnet_ids
}