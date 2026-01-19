# locals.tf

locals {
  workload    = "demo"
  environment = "dev"
  location    = "eastus"
  instance    = "001"

  common_tags = {
    Project   = "SimpleAKS"
    Owner     = "Platform Team"
    ManagedBy = "Terraform"
  }
}
