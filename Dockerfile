# syntax=docker/dockerfile:1

# default build args
ARG DOTNET_VERSION=9.0
ARG RUNTIME_TAG=9.0-noble-chiseled
ARG RUNTIME_DIGEST=sha256:5539e0a2a3c629ccc665b055f0e64aa128a0466c50d136b8cc398a6eac3540ec

# this will be overridden in ci/cd pipeline but is a default build arg
ARG APP_PORT=8080

# the sdk stage is not chiseled,which follows the recommendations of microsoft
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build

ARG BUILD_CONFIGURATION=Release
ARG API_PROJECT=CloudNativeInventory.Api/CloudNativeInventory.Api.csproj

WORKDIR /src

# Multi-stage keeps the final image small since we seperate build artifacts from the runtime image. 
# first stage is to copy the solution COPY ["CloudNativeInventory.sln", "."]
COPY ["global.json", "."]

# then all the versions and settings 
COPY ["Directory.Build.props", "."]
COPY ["Directory.Build.targets", "."]
COPY ["Directory.Packages.props", "."]

# now that we have copied/caches solution -> versions -> settings, we can now copy the project files and lock files
COPY ["CloudNativeInventory.Api/CloudNativeInventory.Api.csproj", "CloudNativeInventory.Api/"]
COPY ["CloudNativeInventory.Api/packages.lock.json", "CloudNativeInventory.Api/"]
COPY ["CloudNativeInventory.Tests/CloudNativeInventory.Tests.csproj", "CloudNativeInventory.Tests/"]
COPY ["CloudNativeInventory.Tests/packages.lock.json", "CloudNativeInventory.Tests/"]


# Restore exact package versions from packages.lock.json.
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet restore "CloudNativeInventory.sln" --locked-mode

# copies the rest of the source code after restore, this helps ensures that normal code changes
# does not invalidate the dependency cache. Docker checks the hash of the files copied in each layer,
# so if only the  source code changes, Docker can still reuse the cached restore layer above.
# bascially by copying the source code after restore, we separate "dependency changes" from "normal code changes",
COPY . .

# publishes   the API project into a clean runtime artifact folder.
RUN --mount=type=cache,target=/root/.nuget/packages \
    dotnet publish "${API_PROJECT}" \
    --configuration "${BUILD_CONFIGURATION}" \
    --no-restore \
    --output "${PUBLISH_DIR}" \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:${RUNTIME_TAG}@${RUNTIME_DIGEST} AS final

ARG APP_PORT

WORKDIR /app

ENV ASPNETCORE_HTTP_PORTS=${APP_PORT}
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE ${APP_PORT}

COPY --from=build /app/publish .

# app is the built-in non-root Linux user in the .NET runtime image.
USER app

ENTRYPOINT ["dotnet", "CloudNativeInventory.Api.dll"]