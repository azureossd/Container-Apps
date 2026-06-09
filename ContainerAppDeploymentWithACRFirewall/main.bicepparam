using 'main.bicep'

// All parameters are now provided via environment variables in deploy.ps1 / deploy.sh.
// This file is kept for reference and can be used for local overrides if needed.
param location = 'westus2'
param containerAppName = 'my-container-app'
param caeName = 'my-container-app-cae'
param identityName = 'my-container-app-identity'
param containerImage = 'myacr.azurecr.io/myapp:1.0'
param acrLoginServer = 'myacr.azurecr.io'
param acrName = 'myacr'
param acrResourceGroup = 'my-app-rg'
