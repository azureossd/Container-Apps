FROM mcr.microsoft.com/dotnet/sdk:5.0-alpine AS build

WORKDIR /source

# copy csproj files
COPY binding-example-dotnet-sdk/*.csproj ./binding-example-dotnet-sdk/
# RUN dotnet restore -r linux-musl-x64

# copy everything else and restore and build app
COPY binding-example-dotnet-sdk/. ./binding-example-dotnet-sdk/
WORKDIR /source/binding-example-dotnet-sdk
RUN dotnet restore -r linux-musl-x64
RUN dotnet build -c release -o /app -r linux-musl-x64
RUN dotnet publish -c release -o /app -r linux-musl-x64 --self-contained false --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0-alpine-amd64
WORKDIR /app
COPY --from=build /app ./

ENTRYPOINT ["dotnet", "binding-example-dotnet-sdk.dll"]
