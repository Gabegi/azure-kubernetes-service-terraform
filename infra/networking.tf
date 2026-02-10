# networking.tf

module "networking" {
  source = "./modules/networking"

  workload            = local.workload
  environment         = local.environment
  location            = local.location
  instance            = local.instance
  resource_group_name = local.rg_name
  common_tags         = local.common_tags

  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    aks = {
      address_prefixes = ["10.0.1.0/24"]
    }
    appgw = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}
