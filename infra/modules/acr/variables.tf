# modules/acr/variables.tf

# ============================================================================
# Naming Variables
# ============================================================================

variable "workload" {
  type        = string
  description = "Workload or application name"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., 'dev', 'prod', 'staging')"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "instance" {
  type        = string
  description = "Instance number (e.g., '001', '002')"
  default     = "001"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to merge with module-generated tags"
  default     = {}
}

# ============================================================================
# Resource Group
# ============================================================================

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

# ============================================================================
# ACR Configuration
# ============================================================================

variable "sku" {
  type        = string
  description = "SKU for the container registry (Basic, Standard, Premium)"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium"
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Enable admin user for the registry"
  default     = false
}
