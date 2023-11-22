# Container Apps Resiliency
This sample Azure Resource Manager template deploys Container Apps that use service resiliency and Dapr resiliency. This template and these applications are provided as-is and come with no guarantees about best-practices. Use at your own discretion.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FResiliency%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2FResiliency%2Fdeploy%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
Deploy a Container App Environment.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

### Azure Storage accounts
One storage account is used with a Dapr queue binding, and the other storage account is used with a Dapr state store. Two storage accounts are deployed so that you can test service down scenarios separately for each of the storage accounts.

### Dapr components and Dapr resiliency policies
- A Storage Queue Dapr component is used as an input binding for the daprresiliency Container App. A resiliency policy deployed for this component to demonstrate the automatic retry behavior when bringing the storage account "offline".
- A Storage Blob Dapr component is used as a state store for the following:
  - In conjunction with the daprresiliency Container App and a resiliency policy to demonstate the automatic retry behavior when bringing the storage account "offline". 
  - To track the number of automatic retries using the appresiliency Container App versus no automatic retries when using the nonappresiliency Container App. 

### Container Apps and service resiliency policies
- **appresiliency** : this Container App is used to demonstrate service resiliency scenarios. A service (app) resiliency policy is also deployed for this Container App.
- **nonappresiliency** : this Container App is used to demonstrate the application without a resiliency policy.
- **clientapp** : This Container App is used to demonstrate communication with the appresiliency Container App, if you set Ingress to internal on the appresiliency Container App. Resiliency for Dapr service-to-service invocation is not supported. This Container App contains placeholder code to test Dapr service-to-service invocation, but it is not supported.
- **grpcappresiliency** : This Container App is used to demonstrate service resiliency with a gRPC HTTP2 app.
- **daprresiliency** : This Container App is used to demonstrate Dapr resiliency.

### Testing the applications.

#### Service resiliency

##### HTTP (external ingress test)

For the appresiliency and nonappresiliency Container Apps, go to the ingress url and choose a resiliency test from the navigation bar.

- The Timeout test Sleeps for 10 seconds. If the timeout policy (which is 5 seconds) is applied, the request should time out with an error. You can click the back button or reload the main page to return to the main page.
- The Http error test returns a 503 error. If the automatic retry resiliency policy isn't present and does not resolve the 503, you will have to click the back button or reload the main page to return to the main page.
- The Http response header test returns a response header of food: home-fries. If the retry policy for response headers is present, the request will be retried when it returns this response header.
- Trip circuit breaker returns a 500. Reloading this page (or any page that returns a 5xx error) consecutively will count towards the circuit breaker threshold. Once the circuit breaker threshold is reached (4 consecutive errors, in our configured test), this will cause the whole site to return "No healthy upstream" for the duration of the circuit breaker interval (1 minute in our configured test).
- For the Http error test, Http response header test, and TripTheCircuitBreaker:
  - Running a test will increase the retry count, which is stored in an external state store. This app can only accomodate tests by one user since the state is tracked via a single key. If the resiliency component (which is outside this app) successfully works, it should automatically retry and increase the retry count.
  - To reset the retry count for subsequent tests, click Reset Retry Count. This will reset the retry count to -1.

##### HTTP (internal ingress test)

If you want to test service resiliency over internal ingress:
1. Set the **appresiliency** Container App to use internal Ingress.
2. From the console of the **clientapp** Container App, use curl to invoke the appresiliency Container App APIs:. You do not need to replace $upstreamacainternaldomain with the appresiliency Container App's domain. This environment variable is already populated with the Container App's internal domain. Belowe is information about the API endpoints of the appresiliency Container App that you can make requests to (via curl).

- Return the current retry count:

```
curl https://$upstreamacainternaldomain/api/retrycount --verbose
```

- Reset the retry count to -1:

```
curl https://$upstreamacainternaldomain/api/ResetRetryCount --verbose
```

- Return a 503 error, which should cause automatic retries for the appresiliency Container App:

```
curl https://$upstreamacainternaldomain/api/HttpErrorTest --verbose
```

- Invoke a request that exceeds the 5-second timeout that is configured on the appresiliency Container App's resiliency policy, which should cause the request to time out with an error:
```
curl https://$upstreamacainternaldomain/api/TimeOutTest --verbose
```

- Return a response header of food: home-fries, which should trigger the appresiliency Container App's resiliency policy for response headers and should cause automatic retries up to the max retry count while the response header is returned:
```
curl https://$upstreamacainternaldomain/api/ResponseHeaderTest --verbose
```

- Returns a 500 error. Make four consecutive requests to this endpoint to trigger the circuit breaker, which will cause the whole appresiliency Container App site to return "No healthy upstream" for the duration of the configured circuit breaker interval (which is 1 minute).

```
curl https://$upstreamacainternaldomain/api/TripTheCircuitBreaker --verbose
```

Note: after you run a HttpErrorTest, ResponseHeaderTest, or TripTheCircuitBreaker to completion, invoke the ResetRetryCount api to reset the retry count for subsequent tests that involve testing automatic retry counts.


##### gRPC over HTTP2 test

If you want to test resiliency over HTTP2 (via gRPC), you can do so by using a gRPC client such as grpcurl to make requests to the grpcappresiliency Container App. Be sure to replace the REPLACE_WITH_YOUR_ENVIROMENT_DOMAIN_SUFFIX text.
Making a request to the fail.FakeFailure/SayFail should return an error of **Unavailable** and cause the policy to retry up to the max retry count that is specified for the policy. The max retry count that is specified in the template is 3.

grpcurl -d "{ \"name\": \"World\" }" grpcappresiliency.REPLACE_WITH_YOUR_ENVIROMENT_DOMAIN_SUFFIX.northcentralusstage.azurecontainerapps.io:443 fail.FakeFailure/SayFail

To verify that the automatic retries occurred, check the logs and verify that "Entering gRPC server failure method." or "Error status code 'Unavailable' with detail 'Failure' raised." was logged four times per request (3 retries + the initial try). E.g.:

```
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(10m)
| where ContainerAppName_s =~ "grpcappresiliency"
| where Log_s == "Entering gRPC server failure method." // or Log_s contains "Error status code 'Unavailable' with detail 'Failure' raised."
```
Note: The greet.Greeter/SayHello gRPC endpoint should return success.

#### Dapr resiliency
1. Go to the ingress url of the daprresiliency Container App, and verify that the State Store page returns values for "Randomly-generated value that was written to state store" and "Value retrieved from state store: 150".
2. In the first storage account (whose name starts with stor1 by default), put a message in the myq1 queue.
3. On the daprresiliency Container App site, verify that the State Store page returns a value for "Value from input binding that was placed in state store".
4. In the second storage account (whose name starts with stor2 by default), on the Networking blade, set Public network access to Disabled. After you save the changes, wait a few minutes.
5. On the daprresiliency Container App site, verify that the State Store page returns "An error occurred when trying to write to the state store." amd "An error occurred when trying to read from the state store."
6. In the logs, verify that you see Dapr retries for this component. E.g:

```
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(10m)
| where ContainerAppName_s =~ "daprresiliency"
| where ContainerName_s == "daprd"
| where Log_s contains "Error processing operation component[mystatestore] output. Retrying in "
| project TimeGenerated, Log_s, ContainerAppName_s, RevisionName_s, EnvironmentName_s
```

Note: The appresiliency and nonappresilency apps rely upon access to the second storage account. If you wish to test those apps again, re-enable access to the second Storage account.

If you want to test the Dapr inbound resiliency policy, disable access on the first storage account and then wait a few minutes. This will tend to generate a large number of logs, so you might want to keep this test short. At this time, inbound policies might incur more retries than desired due to other retry policies compounding them.

If the retries are occurring, you will see numerous occurrences of failures for the input binding. E.g.:
```
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(10m)
| where ContainerAppName_s =~ "daprresiliency"
| where ContainerName_s == "daprd"
| where Log_s contains "mybindingforinput" and Log_s contains "AuthorizationFailure"
| project TimeGenerated, Log_s, ContainerAppName_s, RevisionName_s, EnvironmentName_s
```