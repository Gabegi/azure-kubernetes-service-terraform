output "resource_group" {
  description = "Resource group name"
  value       = "${local.abbreviations.resource_group}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "virtual_network" {
  description = "Virtual network name"
  value       = "${local.abbreviations.virtual_network}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "subnet" {
  description = "Subnet name prefix"
  value       = "${local.abbreviations.subnet}-${var.workload}-${var.environment}-${local.location_code}"
}

output "network_security_group" {
  description = "Network security group name"
  value       = "${local.abbreviations.network_security_group}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "kubernetes_cluster" {
  description = "AKS cluster name"
  value       = "${local.abbreviations.kubernetes_cluster}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "container_registry" {
  description = "Container registry name (alphanumeric only)"
  value       = "${local.abbreviations.container_registry}${var.workload}${var.environment}${local.location_code}${var.instance}"
}

output "key_vault" {
  description = "Key vault name"
  value       = "${local.abbreviations.key_vault}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "log_analytics_workspace" {
  description = "Log Analytics workspace name"
  value       = "${local.abbreviations.log_analytics_workspace}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "storage_account" {
  description = "Storage account name (alphanumeric only)"
  value       = "${local.abbreviations.storage_account}${var.workload}${var.environment}${local.location_code}${var.instance}"
}

output "public_ip" {
  description = "Public IP name"
  value       = "${local.abbreviations.public_ip}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "load_balancer" {
  description = "Load balancer name"
  value       = "${local.abbreviations.load_balancer}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "application_gateway" {
  description = "Application gateway name"
  value       = "${local.abbreviations.application_gateway}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}

output "user_assigned_identity" {
  description = "User assigned identity name"
  value       = "${local.abbreviations.user_assigned_identity}-${var.workload}-${var.environment}-${local.location_code}-${var.instance}"
}
