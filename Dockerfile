# ========================================
# STAGE 1: Build
# ========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar solo el csproj para aprovechar cache
COPY MyApi.csproj ./
RUN dotnet restore MyApi.csproj

# Copiar todo el código fuente
COPY . .
RUN dotnet build MyApi.csproj -c Release -o /app/build

# ========================================
# STAGE 2: Publish
# ========================================
FROM build AS publish
RUN dotnet publish MyApi.csproj -c Release -o /app/publish /p:UseAppHost=false

# ========================================
# STAGE 3: Runtime Final
# ========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Crear usuario no-root (seguridad)
RUN addgroup --system --gid 1001 dotnetgroup && \
    adduser --system --uid 1001 --ingroup dotnetgroup dotnetuser

# Copiar archivos publicados
COPY --from=publish /app/publish .

# Usar usuario no-root
USER dotnetuser

# Configuración de puertos y entorno
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Iniciar la aplicación
ENTRYPOINT ["dotnet", "MyApi.dll"]
