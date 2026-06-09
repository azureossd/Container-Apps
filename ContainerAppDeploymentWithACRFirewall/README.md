# Azure Container App Deployment

Deploy an Azure Container App with a Container Apps Environment, VNet integration, managed identity-based ACR authentication, and ACR firewall lockdown using the Container App's outbound IPs.

## Architecture

- **Container App** with external ingress on port 8080
- **Container Apps Environment** with VNet integration (existing or new subnet)
- **User-Assigned Managed Identity** with AcrPull role for passwordless image pulls
- **ACR Firewall** locked down to only allow traffic from the Container App's outbound IPs

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed (includes Bicep CLI)
- Logged in to Azure (`az login`)
- An existing Azure Container Registry (ACR) with a pushed container image
- The ACR must be **Premium** SKU (required for network rules)
- Sufficient permissions to:
  - Create resource groups, VNets, managed identities, Container Apps
  - Assign RBAC roles on the ACR

## Environment Variables

Set the following environment variables before running the deployment script:

| Variable | Required | Description |
|----------|----------|-------------|
| `DEPLOY_RESOURCE_GROUP` | Yes | Target resource group name |
| `DEPLOY_LOCATION` | Yes | Azure region (e.g. `westus2`) |
| `DEPLOY_CONTAINER_APP` | Yes | Container App name |
| `DEPLOY_CAE_NAME` | Yes | Container Apps Environment name |
| `DEPLOY_IDENTITY_NAME` | Yes | User-assigned managed identity name |
| `DEPLOY_CONTAINER_IMAGE` | Yes | Full container image reference (e.g. `myacr.azurecr.io/myapp:1.0`) |
| `DEPLOY_ACR_LOGIN_SERVER` | Yes | ACR login server (e.g. `myacr.azurecr.io`) — ACR name is derived automatically |
| `DEPLOY_ACR_RG` | Yes | Resource group containing the ACR |
| `DEPLOY_SUBNET_ID` | No | Existing subnet resource ID. If not set, the script prompts to create a new VNet/subnet |

## Usage

### Linux / macOS

```bash
export DEPLOY_RESOURCE_GROUP="my-app-rg"
export DEPLOY_LOCATION="westus2"
export DEPLOY_CONTAINER_APP="my-container-app"
export DEPLOY_CAE_NAME="my-container-app-cae"
export DEPLOY_IDENTITY_NAME="my-container-app-identity"
export DEPLOY_CONTAINER_IMAGE="myacr.azurecr.io/myapp:1.0"
export DEPLOY_ACR_LOGIN_SERVER="myacr.azurecr.io"
export DEPLOY_ACR_RG="my-acr-rg"

chmod +x deploy.sh
./deploy.sh
```

### Windows (PowerShell)

```powershell
$env:DEPLOY_RESOURCE_GROUP   = "my-app-rg"
$env:DEPLOY_LOCATION         = "westus2"
$env:DEPLOY_CONTAINER_APP    = "my-container-app"
$env:DEPLOY_CAE_NAME         = "my-container-app-cae"
$env:DEPLOY_IDENTITY_NAME    = "my-container-app-identity"
$env:DEPLOY_CONTAINER_IMAGE  = "myacr.azurecr.io/myapp:1.0"
$env:DEPLOY_ACR_LOGIN_SERVER = "myacr.azurecr.io"
$env:DEPLOY_ACR_RG           = "my-acr-rg"

.\deploy.ps1
```

### Subnet Options

When `DEPLOY_SUBNET_ID` is not set, the script will prompt:

```
No existing subnet configured (DEPLOY_SUBNET_ID is not set).
Do you want to (1) provide an existing subnet resource ID, or (2) create a new VNet/subnet? [1/2]:
```

- **Option 1**: Enter an existing subnet resource ID (full ARM resource ID)
- **Option 2**: A new VNet (`<container-app-name>-vnet`) with a `/23` subnet delegated to `Microsoft.App/environments` is created in the target resource group

To skip the prompt, set the environment variable:

```bash
export DEPLOY_SUBNET_ID="/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
```

## How It Works

The deployment runs in three passes to handle the ACR firewall chicken-and-egg problem:

1. **First pass** — Deploys infrastructure (identity, VNet if needed, CAE, Container App). ACR firewall rules are not applied yet so the image can be pulled.
2. **Second pass** — Retrieves the Container App's outbound IPs and re-deploys to lock down the ACR firewall (`defaultAction: Deny`) with those IPs allowed.
3. **Third pass** — Re-deploys to ensure the Container App can successfully pull images with the firewall rules fully propagated.

> The first and second passes tolerate failures and continue to the next pass.

## Files

| File | Description |
|------|-------------|
| `main.bicep` | Main Bicep template — orchestrates all resources |
| `main.bicepparam` | Bicep parameters file (for local/reference use) |
| `acr-role-assignment.bicep` | Module: AcrPull role assignment + ACR network rules |
| `vnet.bicep` | Module: VNet and subnet creation (conditional) |
| `deploy.ps1` | PowerShell deployment script (Windows) |
| `deploy.sh` | Bash deployment script (Linux/macOS) |

## Cleanup

To delete all deployed resources:

```bash
az group delete --name <DEPLOY_RESOURCE_GROUP> --yes --no-wait
```

> **Note:** This does not remove the ACR role assignment or firewall rules on the ACR (in a separate resource group). Remove those manually if needed.
