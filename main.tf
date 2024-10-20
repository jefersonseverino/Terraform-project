
module "network" {
  source = "./modules/network"
  candidate = var.candidate
  project = var.project
}

module "ec2" {
  source = "./modules/ec2"
  sg_name = module.network.main_security_group_name
  subnet_id = module.network.main_subnet_id
  bastion_security_group_id = module.network.bastion_security_group_id
  bastion_subnet_id = module.network.bastion_subnet_id
  candidate = var.candidate
  project = var.project
}