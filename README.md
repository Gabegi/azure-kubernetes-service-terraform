# azure-kubernetes-service-terraform

Azure Kubernetes Service with Terraform

This repo is to show a production grade Kubernetes cluster on Azure

## Repository Structure

```
├── infra/          # Terraform infrastructure code
│   ├── modules/    # Reusable Terraform modules
│   └── vars/       # Environment-specific variables
├── src/            # Application source code
│   └── weather-api/
└── README.md
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI
- Azure subscription
- .NET 9 SDK (for the API)

## Configuration

Add your Azure subscription ID to the appropriate tfvars file:

- `infra/vars/dev.tfvars` - Development environment
- `infra/vars/prd.tfvars` - Production environment

## Infrastructure

### Development

```bash
cd infra
terraform init
terraform plan -var-file="vars/dev.tfvars"
terraform apply -var-file="vars/dev.tfvars" -auto-approve
```

### Production

```bash
cd infra
terraform init
terraform plan -var-file="vars/prd.tfvars"
terraform apply -var-file="vars/prd.tfvars" -auto-approve
```

### Destroy

```bash
cd infra

# Development
terraform destroy -var-file="vars/dev.tfvars"

# Production
terraform destroy -var-file="vars/prd.tfvars"
```

## Application

### Weather API

```bash
cd src/weather-api/WeatherApi
dotnet run
```

**Endpoints:**
- `GET /api/health` - Health check
- `GET /api/weather` - 5-day forecast
- `GET /api/weather/{city}` - Weather for specific city
