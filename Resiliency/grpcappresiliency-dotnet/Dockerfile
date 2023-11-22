FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
LABEL Remarks="gET SDK FOM MICROSOFT"
WORKDIR /app
# Copy csproj and restore as distinct layers
COPY GrpcService/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "GrpcService.dll"]