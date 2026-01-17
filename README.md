# azure-kubernetes-service-terraform

Azure Kubernetes Service with Terraform

This repo is to show a production grade Kubernetes cluster on Azure

## Prerequisites

- Terraform >= 1.0
- Azure CLI
- Azure subscription

## Configuration

Add your Azure subscription ID to the appropriate tfvars file:

- `vars/dev.tfvars` - Development environment
- `vars/prd.tfvars` - Production environment

## Usage

### Development

```bash
terraform init
terraform plan -var-file="vars/dev.tfvars"
terraform apply -var-file="vars/dev.tfvars" -auto-approve
```

### Production

```bash
terraform init
terraform plan -var-file="vars/prd.tfvars"
terraform apply -var-file="vars/prd.tfvars" -auto-approve
```

### Destroy

```bash
# Development
terraform destroy -var-file="vars/dev.tfvars"

# Production
terraform destroy -var-file="vars/prd.tfvars"
```
