#!/bin/bash
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

set -e

# Read configuration from environment variables
RESOURCE_GROUP="${DEPLOY_RESOURCE_GROUP}"
LOCATION="${DEPLOY_LOCATION}"
CONTAINER_APP_NAME="${DEPLOY_CONTAINER_APP}"
CAE_NAME="${DEPLOY_CAE_NAME}"
IDENTITY_NAME="${DEPLOY_IDENTITY_NAME}"
CONTAINER_IMAGE="${DEPLOY_CONTAINER_IMAGE}"
ACR_LOGIN_SERVER="${DEPLOY_ACR_LOGIN_SERVER}"
ACR_NAME="${ACR_LOGIN_SERVER%.azurecr.io}"
ACR_RESOURCE_GROUP="${DEPLOY_ACR_RG}"
SUBNET_ID="${DEPLOY_SUBNET_ID}"

# Validate required variables
MISSING=()
[ -z "$RESOURCE_GROUP" ]    && MISSING+=("DEPLOY_RESOURCE_GROUP")
[ -z "$LOCATION" ]          && MISSING+=("DEPLOY_LOCATION")
[ -z "$CONTAINER_APP_NAME" ] && MISSING+=("DEPLOY_CONTAINER_APP")
[ -z "$CAE_NAME" ]          && MISSING+=("DEPLOY_CAE_NAME")
[ -z "$IDENTITY_NAME" ]     && MISSING+=("DEPLOY_IDENTITY_NAME")
[ -z "$CONTAINER_IMAGE" ]   && MISSING+=("DEPLOY_CONTAINER_IMAGE")
[ -z "$ACR_LOGIN_SERVER" ]  && MISSING+=("DEPLOY_ACR_LOGIN_SERVER")
[ -z "$ACR_RESOURCE_GROUP" ] && MISSING+=("DEPLOY_ACR_RG")

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "ERROR: Missing required environment variables:"
    for var in "${MISSING[@]}"; do
        echo "  $var"
    done
    exit 1
fi

# Subnet: prompt user if not set
if [ -z "$SUBNET_ID" ]; then
    echo ""
    echo "No existing subnet configured (DEPLOY_SUBNET_ID is not set)."
    read -rp "Do you want to (1) provide an existing subnet resource ID, or (2) create a new VNet/subnet? [1/2]: " choice
    if [ "$choice" = "1" ]; then
        read -rp "Enter the full subnet resource ID: " SUBNET_ID
        if [ -z "$SUBNET_ID" ]; then
            echo "ERROR: Subnet ID cannot be empty."
            exit 1
        fi
    else
        echo "A new VNet and subnet will be created in resource group '$RESOURCE_GROUP'."
        SUBNET_ID=""
    fi
fi

# Create resource group if it doesn't exist
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Build first pass parameters
FIRST_PASS_PARAMS=(
    "location=$LOCATION"
    "containerAppName=$CONTAINER_APP_NAME"
    "caeName=$CAE_NAME"
    "identityName=$IDENTITY_NAME"
    "containerImage=$CONTAINER_IMAGE"
    "acrLoginServer=$ACR_LOGIN_SERVER"
    "acrName=$ACR_NAME"
    "acrResourceGroup=$ACR_RESOURCE_GROUP"
)
if [ -n "$SUBNET_ID" ]; then
    FIRST_PASS_PARAMS+=("subnetId=$SUBNET_ID")
fi

# First pass: Deploy infrastructure and Container App (ACR stays open)
echo "=== First pass: Deploying infrastructure and Container App ==="
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters "${FIRST_PASS_PARAMS[@]}" \
    --verbose || echo "First pass failed, continuing to retry..."

# Get outbound IPs from the Container App
echo "=== Retrieving Container App outbound IPs ==="
OUTBOUND_IPS_JSON=$(az containerapp show \
    --name "$CONTAINER_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query 'properties.outboundIpAddresses' \
    -o json)

if [ -z "$OUTBOUND_IPS_JSON" ] || [ "$OUTBOUND_IPS_JSON" = "null" ]; then
    echo "ERROR: Could not retrieve outbound IPs. Container App may not exist yet."
    exit 1
fi

echo "Outbound IPs: $OUTBOUND_IPS_JSON"

# If no subnet was provided, get the one that was created
if [ -z "$SUBNET_ID" ]; then
    SUBNET_ID=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name 'vnet-deployment' \
        --query 'properties.outputs.subnetId.value' \
        -o tsv)
fi

# Write a complete ARM parameters file for retries (bicepparam cannot be combined with external parameter files)
OVERRIDE_FILE="$(dirname "$0")/retry.parameters.json"
cat > "$OVERRIDE_FILE" <<EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": { "value": "$LOCATION" },
    "containerAppName": { "value": "$CONTAINER_APP_NAME" },
    "caeName": { "value": "$CAE_NAME" },
    "identityName": { "value": "$IDENTITY_NAME" },
    "containerImage": { "value": "$CONTAINER_IMAGE" },
    "acrLoginServer": { "value": "$ACR_LOGIN_SERVER" },
    "acrName": { "value": "$ACR_NAME" },
    "acrResourceGroup": { "value": "$ACR_RESOURCE_GROUP" },
    "subnetId": { "value": "$SUBNET_ID" },
    "containerAppOutboundIps": { "value": $OUTBOUND_IPS_JSON }
  }
}
EOF

# Second pass: Re-deploy with outbound IPs to lock down ACR firewall
echo "=== Second pass: Locking down ACR with Container App outbound IPs ==="
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters "$OVERRIDE_FILE" \
    --verbose || echo "Second pass failed, continuing to retry..."

# Third pass: Re-deploy to ensure Container App pulls successfully with ACR firewall rules in place
echo "=== Third pass: Final deployment with ACR firewall rules active ==="
az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters "$OVERRIDE_FILE" \
    --verbose

# Clean up temp file
rm -f "$OVERRIDE_FILE"
