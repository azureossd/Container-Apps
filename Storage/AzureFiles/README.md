# Container Apps with Azure File Storage Volume examples
This sample contains examples that deploy a Container App Environment and Container App that mounts a Storage Volume tied to an Azure Files fileshare. 

In both the **ARM** and **Bicep** examples, the following resources are used:

### Log Analytics Workspace

A log Analytics workspace is deployed, which is required for the Container App Environment deployment.

### Application Insights
An Application Insights resource is created.

### Container App Environment

The Container App Environment houses the Container Apps. The Container App Environment also has a **Storages** child resource. The values needed for the child resource come from a Storage Account and Azure File Share. 

### Container App

The Container App example comes with source code to build the Node application's `Dockerfile` in these examples for a complete example. The application in these examples has an endpoint to read off a file named `test.txt` in the configured Azure Files fileshare. This file will first need to exist in the file share configured.
