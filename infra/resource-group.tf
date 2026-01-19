# resource-group.tf

module "resource_group" {
  source = "./modules/resource-group"

  workload    = local.workload
  environment = local.environment
  location    = local.location
  instance    = local.instance
  common_tags = local.common_tags
}
