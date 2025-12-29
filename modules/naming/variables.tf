variable "workload" {
  description = "The workload or application name"
  type        = string
}

variable "environment" {
  description = "The environment (dev, test, prod, etc.)"
  type        = string
}

variable "location" {
  description = "Azure region short name (e.g., eastus, westus2)"
  type        = string
}

variable "instance" {
  description = "Instance number (e.g., 001, 002)"
  type        = string
  default     = "001"
}
