FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build

WORKDIR /source

# copy csproj files
COPY ShowRequestHeaders/*.csproj ./ShowRequestHeaders/
# RUN dotnet restore -r linux-musl-x64

# copy everything else and restore and build app
COPY ShowRequestHeaders/. ./ShowRequestHeaders/
WORKDIR /source/ShowRequestHeaders
RUN dotnet restore -r linux-musl-x64
RUN dotnet build -c release -o /app -r linux-musl-x64
RUN dotnet publish -c release -o /app -r linux-musl-x64 --self-contained false --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine-amd64
WORKDIR /app
COPY --from=build /app ./

ENTRYPOINT ["dotnet", "ShowRequestHeaders.dll"]
