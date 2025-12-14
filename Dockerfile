# ========================================
# STAGE 1: Build
# ========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar .csproj
COPY ["MyApi.csproj", "./"]

# Restaurar dependencias
RUN dotnet restore "MyApi.csproj"

# Copiar todo el código
COPY . .

# Build en modo Release
RUN dotnet build "MyApi.csproj" -c Release -o /app/build

# ========================================
# STAGE 2: Publish
# ========================================
FROM build AS publish
RUN dotnet publish "MyApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ========================================
# STAGE 3: Runtime Final
# ========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copiar archivos publicados
COPY --from=publish /app/publish .

# Puerto
EXPOSE 8080

# Variables de entorno
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Comando de inicio
ENTRYPOINT ["dotnet", "MyApi.dll"]