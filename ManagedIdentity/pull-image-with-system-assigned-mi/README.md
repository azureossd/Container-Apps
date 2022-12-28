# pull-image-with-system-assigned-mi

This is an example of using a System Assigned Identity to pull an image from an Azure Container Registry. The idea is to showcase the notion of not using username or passwords for credentials.

This example creates the following:
- System Assigned Identity
- A Role Assignment, to give the System Assigned Identity the **AcrPull**, so it can pull from said registry (chosen later on, see below).
- Log Analytics Workspace
- Application Insights resource
- Container App Environment
- Container App

At this current time, if deploying with IaC services, such as Bicep, we need to create the Container App using a public image. If trying to use a private registry/a registry that requires authentication in the initial deployment where we set the Role Assignment with Managed Identity, the deployment will time-out.

More details on this can be found [here](https://learn.microsoft.com/en-us/azure/container-apps/managed-identity-image-pull?tabs=azure-cli&pivots=command-line#system-assigned-managed-identity-1).

The current guidance is after setting up the Container App (with MSI), it can be updated to point to the private/authenticated registry.

To run this, populate the environment variables needed in the `az-deployment-command.sh` file. Then, run the `az` command defined in the script.

