# modules/networking/variables.tf

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
# VNet Configuration
# ============================================================================

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
  default     = ["10.0.0.0/16"]
}

# ============================================================================
# Subnet Configuration
# ============================================================================

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = "Map of subnets to create"
  default = {
    aks = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}
