variable "workload" {
  description = "The workload or application name"
  type        = string
}

variable "environment" {
  description = "The environment (dev, test, prod, etc.)"
  type        = string
}

variable "owner" {
  description = "Owner or contact email"
  type        = string
}

variable "cost_center" {
  description = "Cost center or department"
  type        = string
  default     = ""
}

variable "criticality" {
  description = "Business criticality (Low, Medium, High, Critical)"
  type        = string
  default     = "Medium"
}

variable "data_classification" {
  description = "Data classification level (Public, Internal, Confidential, Restricted)"
  type        = string
  default     = "Internal"
}

variable "additional_tags" {
  description = "Additional custom tags"
  type        = map(string)
  default     = {}
}
