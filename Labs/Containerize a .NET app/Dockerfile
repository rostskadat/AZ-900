FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /ConsoleApp
COPY ConsoleApp /ConsoleApp
RUN dotnet restore
RUN dotnet publish --configuration Release --output out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /ConsoleApp
COPY --from=build-env /ConsoleApp/out .
ENTRYPOINT ["dotnet", "DotNet.Docker.dll"]
