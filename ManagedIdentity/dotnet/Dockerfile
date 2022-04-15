FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
WORKDIR /source

# copy csproj files
COPY ManagedIdentity/*.csproj ./ManagedIdentity/
RUN dotnet restore "ManagedIdentity/ManagedIdentity.csproj"

# copy everything else and restore and build app
COPY . .
WORKDIR /source/ManagedIdentity
RUN dotnet build "ManagedIdentity.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ManagedIdentity.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# ENTRYPOINT export ASPNETCORE_ENVIRONMENT=Development && exec dotnet "ManagedIdentity.dll"
ENTRYPOINT ["dotnet", "ManagedIdentity.dll"]

