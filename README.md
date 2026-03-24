# azure-kubernetes-service-terraform

Production-grade AKS deployment on Azure with Terraform IaC, Blazor frontend, .NET backend, PostgreSQL, Application Gateway WAF, and GitHub Actions CI/CD.

## Architecture

```
Internet → Azure Application Gateway (WAF_v2)
               ├── /api/* → weather-backend (ASP.NET Core API)
               └── /*     → weather-frontend (Blazor Server)
                               └── http://weather-backend-service (internal K8s DNS)

AKS Cluster
├── weather-frontend (2 replicas, sticky sessions via App Gateway)
├── weather-backend  (2 replicas, HPA min 2 / max 10)
└── postgres         (StatefulSet, 5Gi managed-csi PVC)
```

**Public URL:** `http://weather-demo-dev.eastus.cloudapp.azure.com`

---

## Prerequisites

- Terraform >= 1.0
- Azure CLI
- .NET 9 SDK
- kubectl
- Docker

---

## Quick Start

### 1. Pre-requisites (one-time, manual)

Create the resource group and storage account for Terraform remote state:
```bash
az group create --name rg-demo-dev-eus-001 --location eastus

az storage account create \
  --name bestnamesa \
  --resource-group rg-demo-dev-eus-001 \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name bestnamesa
```

Create a service principal and grant it Owner on the resource group:
```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role Owner \
  --scopes /subscriptions/<subscription-id>/resourceGroups/rg-demo-dev-eus-001 \
  --sdk-auth
```

### 2. Set Up GitHub Secrets

Go to your repo → **Settings** → **Secrets and variables** → **Actions**:

- **Secret:** `AZURE_CREDENTIALS` — paste the full JSON output from the SP creation above

### 3. Deploy Infrastructure

Go to GitHub Actions → **Deploy Infrastructure** → Run workflow.

This provisions: AKS, ACR, Application Gateway (WAF_v2), VNet, Log Analytics.

### 4. Build and Deploy App

Go to GitHub Actions → **Build and Deploy App** → Run workflow.

This builds Docker images, pushes to ACR, and deploys all Kubernetes manifests in order:
1. PostgreSQL StatefulSet (waits for ready)
2. Backend + Frontend Deployments
3. HPA + Ingress

### 5. Verify

```bash
az aks get-credentials --resource-group rg-demo-dev-eus-001 --name aks-demo-dev-eus-001

kubectl get pods
kubectl get ingress
```

### 6. Destroy Infrastructure

Go to GitHub Actions → **Destroy Infrastructure** → Run workflow.

---

## Repository Structure

```
├── infra/                        # Terraform infrastructure
│   ├── modules/
│   │   ├── aks/                  # AKS module (node pool, AGIC, RBAC)
│   │   ├── acr/                  # Azure Container Registry
│   │   ├── networking/           # VNet, subnets (aks, appgw)
│   │   ├── naming/               # Naming convention helper
│   │   └── tagging/              # Common tags
│   ├── vars/
│   │   └── dev.tfvars            # Dev environment variables
│   ├── aks.tf
│   ├── app_gateway.tf            # App Gateway, WAF policy, AGIC role assignments
│   ├── networking.tf
│   ├── providers.tf              # Azure provider + remote state backend
│   └── resource-group.tf
├── src/
│   ├── weather-api/              # ASP.NET Core 9 Web API
│   │   ├── Controllers/
│   │   │   ├── WeatherController.cs  # GET/POST /api/weather
│   │   │   └── HealthController.cs   # GET /api/health
│   │   ├── Data/
│   │   │   └── WeatherDbContext.cs   # EF Core DbContext
│   │   ├── Models/
│   │   │   └── WeatherData.cs        # WeatherRecords entity
│   │   └── Migrations/               # EF Core migrations (auto-applied on startup)
│   └── weather-frontend/         # Blazor Server (.NET 9)
│       └── Components/Pages/
│           └── Weather.razor         # Weather list + add form (InteractiveServer)
├── k8s/                          # Kubernetes manifests
│   ├── postgres-statefulset.yaml # PostgreSQL 15, Service, Secret, 5Gi PVC
│   ├── backend-manifest.yaml     # Backend Deployment + ClusterIP Service
│   ├── frontend-manifest.yaml    # Frontend Deployment + ClusterIP Service
│   ├── backend-hpa.yaml          # HPA: CPU/memory 70%, min 2 / max 10
│   └── ingress.yaml              # Split ingress: backend (30s) + frontend (sticky, 3600s)
└── .github/workflows/
    ├── build-push.yaml           # Build images + deploy to AKS (manual)
    ├── infrastructure.yml        # Terraform apply (manual)
    └── destroy.yml               # Terraform destroy (manual)
```

---

## Infrastructure Details

| Resource | Name | Notes |
|---|---|---|
| Resource Group | `rg-demo-dev-eus-001` | Pre-created manually |
| AKS | `aks-demo-dev-eus-001` | Standard_D2s_v3, min 3 / max 6 nodes |
| ACR | `acrdemodeveus001` | Attached to AKS |
| App Gateway | `agw-demo-dev-eus-001` | WAF_v2, Microsoft_DefaultRuleSet 2.1 |
| Public IP / DNS | `pip-agw-demo-dev-eus-001` | `weather-demo-dev.eastus.cloudapp.azure.com` |
| PostgreSQL | In-cluster StatefulSet | `managed-csi` storage class, 5Gi |

---

## Application

### API Endpoints

- `GET /api/health` — Health check
- `GET /api/weather` — List all weather records from DB
- `POST /api/weather` — Save a new weather record `{ "city": "London", "temperature": 18 }`

### Local Development

```bash
# Start PostgreSQL
docker run -d --name weatherdb \
  -e POSTGRES_DB=weatherdb \
  -e POSTGRES_USER=weatheruser \
  -e POSTGRES_PASSWORD=weatherpass123 \
  -p 5432:5432 postgres:15-alpine

# Backend API (Terminal 1)
cd src/weather-api
dotnet run

# Frontend (Terminal 2)
cd src/weather-frontend
dotnet run
```

EF Core migrations run automatically on startup.

### Notes

- The frontend uses **Blazor Server InteractiveServer** mode (SignalR). Cookie-based affinity is enabled on the App Gateway to ensure sticky sessions.
- Connection string is injected via Kubernetes env var `ConnectionStrings__DefaultConnection` — overrides `appsettings.json` at runtime.
- frontend-hpa.yaml not implemented.
