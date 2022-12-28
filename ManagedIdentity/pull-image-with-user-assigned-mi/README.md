# pull-image-with-user-assigned-mi

This is an example of using a User Assigned Identity to pull an image from an Azure Container Registry. The idea is to showcase the notion of not using username or passwords for credentials.

This example creates the following:
- User Assigned Identity
- A Role Assignment, to give the User Assigned Identity the **AcrPull**, so it can pull from said registry.
- Log Analytics Workspace
- Application Insights resource
- Container App Environment
- Container App

To run this, populate the environment variables needed in the `az-deployment-command.sh` file. Then, run the `az` command defined in the script.
