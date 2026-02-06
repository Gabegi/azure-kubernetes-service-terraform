# azure-kubernetes-service-terraform

Azure Kubernetes Service with Terraform

This repo deploys a production-grade Kubernetes cluster on Azure with a sample .NET application.

## Quick Start

### 1. Deploy Infrastructure
```bash
cd infra
terraform init
terraform plan -var-file="vars/dev.tfvars"
terraform apply -var-file="vars/dev.tfvars" -auto-approve
```

### 2. Set Up GitHub Secrets
- Add secret `AZURE_CREDENTIALS` - Service principal JSON
- Add variable `ACR_NAME` - Your ACR name

### 3. Build and Push Images
Go to GitHub Actions → "Build and Push to ACR" → Run workflow

### 4. Connect to AKS
```bash
az aks get-credentials --resource-group rg-demo-dev-eus-001 --name aks-demo-dev-eus-001
```

### 5. Update Manifests with ACR Name
```bash
sed -i 's/ACR_NAME/<your-acr-name>/g' k8s/*.yaml
```

### 6. Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

### 7. Verify Deployment
```bash
kubectl get pods
kubectl get svc
```

The frontend LoadBalancer service will get an external IP after a minute. Access your app at that IP.

---

## Repository Structure

```
├── infra/                    # Terraform infrastructure
│   ├── modules/              # Reusable modules (aks, acr, networking, etc.)
│   └── vars/                 # Environment variables (dev.tfvars, prd.tfvars)
├── src/                      # Application source code
│   ├── weather-api/          # .NET Backend API
│   └── weather-frontend/     # Blazor Frontend
├── k8s/                      # Kubernetes manifests
│   ├── weather-api.yaml
│   └── weather-frontend.yaml
└── .github/workflows/        # CI/CD pipelines
    └── build-push.yaml       # Build and push images to ACR
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI
- Azure subscription
- .NET 9 SDK
- kubectl

## Infrastructure

Add your Azure subscription ID to `infra/vars/dev.tfvars`:

```hcl
subscription_id = "your-subscription-id"
```

### Deploy

```bash
cd infra
terraform init
terraform plan -var-file="vars/dev.tfvars"
terraform apply -var-file="vars/dev.tfvars" -auto-approve
```

### Destroy

```bash
cd infra
terraform destroy -var-file="vars/dev.tfvars"
```

## Application

### Local Development

```bash
# Backend API (Terminal 1)
cd src/weather-api
dotnet run

# Frontend (Terminal 2)
cd src/weather-frontend
dotnet run
```

**API Endpoints:**
- `GET /api/health` - Health check
- `GET /api/weather` - 5-day forecast
- `GET /api/weather/{city}` - Weather for specific city

### Build Docker Images

```bash
# API
docker build -t weather-api:latest src/weather-api/

# Frontend
docker build -t weather-frontend:latest src/weather-frontend/
```

### Push to ACR

```bash
# Login to ACR
az acr login --name <acr-name>

# Tag and push
docker tag weather-api:latest <acr-name>.azurecr.io/weather-api:latest
docker push <acr-name>.azurecr.io/weather-api:latest

docker tag weather-frontend:latest <acr-name>.azurecr.io/weather-frontend:latest
docker push <acr-name>.azurecr.io/weather-frontend:latest
```

## Kubernetes Deployment

### Connect to AKS

```bash
az aks get-credentials --resource-group rg-demo-dev-eus-001 --name aks-demo-dev-eus-001
```

### Update Manifests

Replace `ACR_NAME` in `k8s/*.yaml` with your ACR name.

### Deploy

```bash
kubectl apply -f k8s/
```

### Verify

```bash
kubectl get pods
kubectl get services
```

## CI/CD

GitHub Actions workflow (`.github/workflows/build-push.yaml`) builds and pushes images to ACR.

**Setup:**
1. Add secret `AZURE_CREDENTIALS` (service principal JSON)
2. Add variable `ACR_NAME` (your ACR name)

Trigger manually from GitHub Actions.
