locals {
  # Azure resource abbreviations based on Microsoft CAF
  abbreviations = {
    resource_group              = "rg"
    virtual_network             = "vnet"
    subnet                      = "snet"
    network_security_group      = "nsg"
    kubernetes_cluster          = "aks"
    container_registry          = "acr"
    key_vault                   = "kv"
    log_analytics_workspace     = "log"
    storage_account             = "st"
    public_ip                   = "pip"
    load_balancer               = "lb"
    application_gateway         = "agw"
    user_assigned_identity      = "id"
  }

  # Location abbreviations
  location_short = {
    eastus        = "eus"
    eastus2       = "eus2"
    westus        = "wus"
    westus2       = "wus2"
    centralus     = "cus"
    northeurope   = "neu"
    westeurope    = "weu"
    southeastasia = "sea"
    eastasia      = "eas"
    uksouth       = "uks"
    ukwest        = "ukw"
  }

  location_code = lookup(local.location_short, var.location, substr(var.location, 0, 3))
}
