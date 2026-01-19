locals {
  # Core tags based on Microsoft best practices
  core_tags = {
    Environment        = var.environment
    Workload          = var.workload
    Owner             = var.owner
    ManagedBy         = "Terraform"
    Criticality       = var.criticality
    DataClassification = var.data_classification
  }

  # Optional cost center tag
  cost_center_tag = var.cost_center != "" ? {
    CostCenter = var.cost_center
  } : {}

  # Merge all tags
  tags = merge(
    local.core_tags,
    local.cost_center_tag,
    var.additional_tags
  )
}
