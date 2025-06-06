Rule-based routing with Container Apps via custom domain

This sample Azure Resource Manager template deploys two Container Apps to route traffic to, using rule-based routing.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FRuleBasedRouting%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FDapr%2Fpubsub-programmatic%2Fnodejs%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
1. A deployed Container App Environment. You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.
2. A current version of Azure CLI. 2.73.0 or later should work.
3. 1-2 custom domains.
4. Configure DNS for your custom domain(s):
   - If using the root domain, create an A record named @ pointing to the Container App Environment's inbound static IP, and a TXT record named asuid pointing to the Container App Environment's TXT verification value.
   - If using a subdomain (e.g. www. at the beginning), create an A record named www (or whatever the subdomain prefix is) pointing to the Container App Environment's inbound static IP, and a TXT record named asuid.www (or asuid.ReplaceWithSubdomainPrefix) pointing to the Container App Environment's TXT verification value.

### Postrerequisites
After completing the prerequisites and completing the deployment of the Container Apps, do the following:
1. Copy the routing_rules1.yml and/or routing_rules2.yml that are found in the routing_rules folder to your local machine.
2. In the yml file(s), enter the custom domain in the name property under customDomains. You can only use one custom domain per rules file, and the custom domains must be different.
3. Apply a rule(s) to the environment. E.g.:
    ```
	az containerapp env http-route-config create --resource-group YourResourceGroup --name YourManagedEnvironmentName --http-route-config-name routingrule1 --yaml routing_rules1.yml
    ```	
4. For each domain, bind a certificate to the environment. You can use the Az CLI to do this. E.g.:

```
az containerapp env certificate create -g YourResourceGroup --name YourManagedEnvironmentName --certificate-name GiveItAFriendlyName --hostname YourCustomDomain --validation-method HTTP
```

Note: Even after the certificate is successfully added, it may take several minutes before it is provisioned. In the meantime, you might get ERR_CONNECTION_RESET or a similar message when you try to access the custom domain.
After the certificate is provisioned, you will get 404/Not found if you request a route that doesn't exist, such as the / (root) route.

### Test the app

Note: Rewrite is a server-side action. So for rewrite actions, you will not see the rewritten URL in the browser.

**If using routing_rules1.yml**:

https://YourCustomDomain/givemeabiscuit

This should rewrite to the /biscuits route on backendapp1 and return content.

https://YourCustomDomain/i/like/donuts

This should rewrite to the /donuts/maple route on backendapp1 and return content.

https://YourCustomDomain/givemesomegravy

This should rewrite to the /gravy route on backendapp2 and return content.

**If using routing_rules2.yml**:

https://YourCustomDomain/biscuit

This should return a 404 because an exact match is expected, and backendapp1's route is /biscuits (with an s at the end).

https://YourCustomDomain/biscuits

This should route to the /biscuits route on backendapp1 and return content, because it is an exact match.

https://YourCustomDomain/biscuits/

This should return a 404 because an exact match is expected, and backendapp1's route is /biscuits (without a / at the end).

https://YourCustomDomain/donuts/maple

This should route to the /donuts/maple route on backendapp1 and return content, because the rule has pathSeparatedPrefix: "/donuts", which allows rewrite if there is a / after /donuts, followed by a valid subpath on the target app.

https://YourCustomDomain/givemesomegravy

This should rewrite to the /gravy route on backendapp2 and return content.

https://YourCustomDomain/gravy

This should route to the /gravy route on backendapp2 and return content, because it is an exact match.

