# Pull Image with System Assigned Managed Identity through Terraform

This example demonstrates how to use a **System Assigned Identity** to pull an image from an **Azure Container Registry (ACR)** without using usernames or passwords for credentials.

---

## Overview

This example creates the following resources:

- **System Assigned Identity**
- **Role Assignment**: Grants the System Assigned Identity the `AcrPull` role so it can pull from the registry.
- **Container App Environment**
- **Container App**

---

## Ideal Scenario

Run the following command to apply the configuration:

```bash
terraform apply
```

---

## Common Issues

You may encounter errors such as:

- `invalid value: acrname.azurecr.io/image:tag`
- Unable to pull image using Managed Identity for registry

These issues often occur due to race conditions where the System Assigned Identity is not created in time. This is similar to the "chicken and egg" problem reported for other Azure Container Apps (ACA) scenarios.

For more details, refer to:  
[GitHub Issue: azure-container-apps #836](https://github.com/microsoft/azure-container-apps/issues/836)

---

## Workaround: Two-Step Process

Until the issue is fully resolved, follow these steps:

### **Step 1: Create ACA with Default Image**
Use a default image (`mcr.microsoft.com/k8se/quickstart:latest`) without a custom registry/image.  
This step ensures the System Managed Identity is created with the correct permissions.

Apply the following commands:

```
cd default
terraform init
terraform apply
```
**Important:** There is no direct command like terraform apply `file.tf` because Terraform treats the entire directory as the configuration set.

---

### **Step 2: Switch to Custom Registry/Image**
Update the Container App to use your custom registry/image and reapply changes.

Apply the following commands:

```
cd ..
terraform init

# run 'terraform import azurerm_container_app_environment.env "full-environment-resource-id"' if required / prompted
# run 'terraform import azurerm_container_app.app "full-app-resource-id"' if required / prompted

terraform apply
```

> **Note:** You can use your own template, but ensure all required elements are included.

---

## Summary

- Avoid using credentials by leveraging **System Assigned Identity**.
- Use a **two-step deployment** process to mitigate race condition issues.
- Refer to the GitHub issue for ongoing updates.