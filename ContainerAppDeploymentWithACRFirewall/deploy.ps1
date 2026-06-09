# Deploy Azure Container App with Container Apps Environment
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Bicep CLI installed (comes with Azure CLI)
#   - Sufficient permissions to create resources and assign roles
#
# Environment Variables:
#   DEPLOY_RESOURCE_GROUP   - Target resource group name
#   DEPLOY_LOCATION         - Azure region (e.g. westus2)
#   DEPLOY_CONTAINER_APP    - Container App name
#   DEPLOY_CAE_NAME         - Container Apps Environment name
#   DEPLOY_IDENTITY_NAME    - User-assigned managed identity name
#   DEPLOY_CONTAINER_IMAGE  - Full container image reference (e.g. myacr.azurecr.io/app:1.0)
#   DEPLOY_ACR_LOGIN_SERVER - ACR login server (e.g. myacr.azurecr.io)
#   DEPLOY_ACR_RG           - Resource group containing the ACR
#   DEPLOY_SUBNET_ID        - (Optional) Existing subnet resource ID for CAE

# Read configuration from environment variables
$ResourceGroup    = $env:DEPLOY_RESOURCE_GROUP
$Location         = $env:DEPLOY_LOCATION
$ContainerAppName = $env:DEPLOY_CONTAINER_APP
$CaeName          = $env:DEPLOY_CAE_NAME
$IdentityName     = $env:DEPLOY_IDENTITY_NAME
$ContainerImage   = $env:DEPLOY_CONTAINER_IMAGE
$AcrLoginServer   = $env:DEPLOY_ACR_LOGIN_SERVER
$AcrName          = $AcrLoginServer -replace '\.azurecr\.io$', ''
$AcrResourceGroup = $env:DEPLOY_ACR_RG
$SubnetId         = $env:DEPLOY_SUBNET_ID

# Validate required variables
$required = @{
    'DEPLOY_RESOURCE_GROUP'   = $ResourceGroup
    'DEPLOY_LOCATION'         = $Location
    'DEPLOY_CONTAINER_APP'    = $ContainerAppName
    'DEPLOY_CAE_NAME'         = $CaeName
    'DEPLOY_IDENTITY_NAME'    = $IdentityName
    'DEPLOY_CONTAINER_IMAGE'  = $ContainerImage
    'DEPLOY_ACR_LOGIN_SERVER' = $AcrLoginServer
    'DEPLOY_ACR_RG'           = $AcrResourceGroup
}

$missing = $required.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key }
if ($missing) {
    Write-Host "ERROR: Missing required environment variables:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}

# Subnet: prompt user if not set
if (-not $SubnetId) {
    Write-Host ""
    Write-Host "No existing subnet configured (DEPLOY_SUBNET_ID is not set)." -ForegroundColor Yellow
    $choice = Read-Host "Do you want to (1) provide an existing subnet resource ID, or (2) create a new VNet/subnet? [1/2]"
    if ($choice -eq '1') {
        $SubnetId = Read-Host "Enter the full subnet resource ID"
        if (-not $SubnetId) {
            Write-Host "ERROR: Subnet ID cannot be empty." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "A new VNet and subnet will be created in resource group '$ResourceGroup'." -ForegroundColor Cyan
        $SubnetId = ''
    }
}

# Create resource group if it doesn't exist
az group create --name $ResourceGroup --location $Location

# First pass: Deploy infrastructure and Container App (ACR stays open)
Write-Host "=== First pass: Deploying infrastructure and Container App ===" -ForegroundColor Cyan
$firstPassParams = @(
    "location=$Location"
    "containerAppName=$ContainerAppName"
    "caeName=$CaeName"
    "identityName=$IdentityName"
    "containerImage=$ContainerImage"
    "acrLoginServer=$AcrLoginServer"
    "acrName=$AcrName"
    "acrResourceGroup=$AcrResourceGroup"
)
if ($SubnetId) {
    $firstPassParams += "subnetId=$SubnetId"
}

az deployment group create `
    --resource-group $ResourceGroup `
    --template-file main.bicep `
    --parameters $firstPassParams `
    --verbose

# Get outbound IPs from the Container App
Write-Host "=== Retrieving Container App outbound IPs ===" -ForegroundColor Cyan
$outboundIpsJson = (az containerapp show `
    --name $ContainerAppName `
    --resource-group $ResourceGroup `
    --query 'properties.outboundIpAddresses' `
    -o json) -join ''

Write-Host "Outbound IPs: $outboundIpsJson"

# If no subnet was provided, get the one that was created
if (-not $SubnetId) {
    $SubnetId = (az deployment group show `
        --resource-group $ResourceGroup `
        --name 'vnet-deployment' `
        --query 'properties.outputs.subnetId.value' `
        -o tsv)
}

# Write a complete ARM parameters file for retries (bicepparam cannot be combined with external parameter files)
$allParams = @{
    '`$schema' = 'https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#'
    contentVersion = '1.0.0.0'
    parameters = @{
        location                = @{ value = $Location }
        containerAppName        = @{ value = $ContainerAppName }
        caeName                 = @{ value = $CaeName }
        identityName            = @{ value = $IdentityName }
        containerImage          = @{ value = $ContainerImage }
        acrLoginServer          = @{ value = $AcrLoginServer }
        acrName                 = @{ value = $AcrName }
        acrResourceGroup        = @{ value = $AcrResourceGroup }
        subnetId                = @{ value = $SubnetId }
        containerAppOutboundIps = @{ value = ($outboundIpsJson | ConvertFrom-Json) }
    }
} | ConvertTo-Json -Depth 5

$overrideFile = Join-Path $PSScriptRoot 'retry.parameters.json'
$allParams | Out-File -FilePath $overrideFile -Encoding utf8

# Second pass: Re-deploy with outbound IPs to lock down ACR firewall
Write-Host "=== Second pass: Locking down ACR with Container App outbound IPs ===" -ForegroundColor Cyan
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file main.bicep `
    --parameters $overrideFile `
    --verbose

# Third pass: Re-deploy to ensure Container App pulls successfully with ACR firewall rules in place
Write-Host "=== Third pass: Final deployment with ACR firewall rules active ===" -ForegroundColor Cyan
az deployment group create `
    --resource-group $ResourceGroup `
    --template-file main.bicep `
    --parameters $overrideFile `
    --verbose

# Clean up temp file
Remove-Item $overrideFile -ErrorAction SilentlyContinue
