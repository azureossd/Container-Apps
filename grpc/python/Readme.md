# gRPC Server on Container Apps
This sample Azure Resource Manager template deploys a Container App that runs a gRPC server.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2Fgrpc%2Fpython%2Fdeploy%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazureossd%2FContainer-Apps%2Fmaster%2Fgrpc%2Fpython%2Fdeploy%2Fazuredeploy.json)

### Prerequisites
Deploy a Container App Environment.
You can use [this template](https://github.com/azureossd/Container-Apps/tree/master/ContainerAppEnvironment/deploy) to deploy a Container App Environment.

### Container App
The application is taken from [https://github.com/r0mk1/grpc-helloworld-reflection-docker](https://github.com/r0mk1/grpc-helloworld-reflection-docker)

The Ingress port on the Contaier App is 443.

You can use grpcurl or another grpc client to test connectivity to the server.
Note: There are numerous ways to install grpcurl. Refer to [this page](https://repology.org/project/grpcurl/information) for a list of grpc packages, including Windows packages. Refer to [this page](https://github.com/fullstorydev/grpcurl) for more information about grpcurl.

The grpc hostname:port of the Container App-hosted GRPC server will resemble the following:
grpcserver.<ContainerAppEnvironmentFQDNPrefix>.<REGION>.azurecontainerapps.io:443

Replace the hostname with your Container App hostname.

To test the grpc server via grpcurl"

Run the following to list the avalable services:

```
grpcurl grpcserver.<ContainerAppEnvironmentFQDNPrefix>.<REGION>.azurecontainerapps.io:443 list
```

The output should resemble the following:

```
grpc.reflection.v1alpha.ServerReflection
helloworld.Greeter
```

Run the following to list the avalable methods on the helloworld.Greeter service:

```
grpcurl -plaintext grpcserver.icycliff-f9e96c63.canadacentral.azurecontainerapps.io:443 list helloworld.Greeter
```

The output should resemble the following:

```
helloworld.Greeter.SayHello
```

Run the following to invoke the SayHello method:

```
grpcurl -plaintext localhost:50051 helloworld.Greeter.SayHello
```

The output should resemble the following:

```
{
  "message": "Hello, !"
}
```

If you want to monitor the port and protocol used in the Container App, you can use a tool such as netstat from the Container App Console. You will need to scale the Container App to at least one replica to connect to the Console.

To install netstat, run the following commands from the Container App Console:

```
apt update && apt upgrade -y

apt install net-tools
```

To use netstat to check the list of processes by port and protocol, run the following command:

```
netstat -tulpn | grep LISTEN
```

For this gRPC server, the output should contain a line that resembles the following:

| | | | | | | |
| - | - |- | - | - | - | - |
| tcp6 | 0 | 0 | :::50051 | :::`*` | LISTEN | 7/python |