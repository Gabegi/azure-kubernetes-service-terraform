# app_gateway.tf

# WAF Policy
resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-${local.workload}-${local.environment}-eus-${local.instance}"
  location            = local.location
  resource_group_name = local.rg_name

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
  }

  tags = local.common_tags
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "pip-agw-${local.workload}-${local.environment}-eus-${local.instance}"
  location            = local.location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "agw-${local.workload}-${local.environment}-eus-${local.instance}"
  location            = local.location
  resource_group_name = local.rg_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.main.id

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = module.networking.subnet_ids["appgw"]
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  # Placeholder backend - AGIC will manage this
  backend_address_pool {
    name = "placeholder"
  }

  backend_http_settings {
    name                  = "placeholder"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "placeholder"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "placeholder"
    rule_type                  = "Basic"
    http_listener_name         = "placeholder"
    backend_address_pool_name  = "placeholder"
    backend_http_settings_name = "placeholder"
    priority                   = 100
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  # AGIC manages the App Gateway config - ignore changes it makes
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      probe,
      frontend_port,
      redirect_configuration,
      url_path_map,
      tags["managed-by-k8s-ingress"],
    ]
  }

  tags = local.common_tags
}

# Outputs
output "app_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.main.id
}

output "app_gateway_public_ip" {
  description = "Application Gateway public IP address"
  value       = azurerm_public_ip.appgw.ip_address
}
