FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# we copy the solution and project files first since Docker can cache the restore step whenever the project files are unchanged!
COPY ["CloudNativeInventory.sln", "."]
COPY ["global.json", "."]
COPY ["CloudNativeInventory.Api/CloudNativeInventory.Api.csproj", "CloudNativeInventory.Api/"]
COPY ["CloudNativeInventory.Tests/CloudNativeInventory.Tests.csproj", "CloudNativeInventory.Tests/"]


# then we restore the solution after caching the project files, so that we don't have to restore the solution every time we change the source code
RUN dotnet restore "CloudNativeInventory.sln"

COPY . .

RUN dotnet publish "CloudNativeInventory.Api/CloudNativeInventory.Api.csproj" -c Release -o /app/publish -p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app


## configures asp.net core to listen to port 8080 inside container
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080



COPY --from=build /app/publish .

# app (or UID  1654)  is the pre-made default nonroot user by Windows. 
# this ensures that the process doesnt run as admin (UID 0)
USER app

ENTRYPOINT ["dotnet", "CloudNativeInventory.Api.dll"]
