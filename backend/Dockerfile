# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["FullstackUser.csproj", "./"]
RUN dotnet restore "FullstackUser.csproj"
COPY . .
RUN dotnet build "FullstackUser.csproj" -c Release -o /app/build
RUN dotnet publish "FullstackUser.csproj" -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 5000
ENTRYPOINT ["dotnet", "FullstackUser.dll"]

