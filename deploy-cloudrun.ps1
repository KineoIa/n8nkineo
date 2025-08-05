# Script para desplegar n8n en Google Cloud Run
# Asegúrate de tener configurado gcloud CLI

# Variables de configuración
$PROJECT_ID = "tu-proyecto-gcp"
$REGION = "us-central1"
$SERVICE_NAME = "n8n-service"
$DB_INSTANCE_NAME = "n8n-db-instance"
$DB_NAME = "n8n"
$DB_USER = "n8n_user"
$DB_PASSWORD = "SecurePassword123!"

Write-Host "=== Configurando Google Cloud Project ===" -ForegroundColor Green
gcloud config set project $PROJECT_ID

Write-Host "=== Habilitando APIs necesarias ===" -ForegroundColor Green
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudbuild.googleapis.com

Write-Host "=== Creando instancia de Cloud SQL (PostgreSQL) ===" -ForegroundColor Green
gcloud sql instances create $DB_INSTANCE_NAME `
    --database-version=POSTGRES_13 `
    --tier=db-f1-micro `
    --region=$REGION

Write-Host "=== Configurando base de datos ===" -ForegroundColor Green
gcloud sql databases create $DB_NAME --instance=$DB_INSTANCE_NAME
gcloud sql users create $DB_USER --instance=$DB_INSTANCE_NAME --password=$DB_PASSWORD

Write-Host "=== Obteniendo IP de Cloud SQL ===" -ForegroundColor Green
$SQL_IP = gcloud sql instances describe $DB_INSTANCE_NAME --format="value(ipAddresses[0].ipAddress)"
Write-Host "IP de Cloud SQL: $SQL_IP" -ForegroundColor Yellow

Write-Host "=== Desplegando n8n en Cloud Run ===" -ForegroundColor Green
gcloud run deploy $SERVICE_NAME `
    --image=n8nio/n8n `
    --platform=managed `
    --region=$REGION `
    --allow-unauthenticated `
    --port=5678 `
    --memory=2Gi `
    --cpu=1 `
    --timeout=300 `
    --set-env-vars="N8N_BASIC_AUTH_ACTIVE=true" `
    --set-env-vars="N8N_BASIC_AUTH_USER=admin" `
    --set-env-vars="N8N_BASIC_AUTH_PASSWORD=admin123" `
    --set-env-vars="DB_TYPE=postgresdb" `
    --set-env-vars="DB_POSTGRESDB_HOST=$SQL_IP" `
    --set-env-vars="DB_POSTGRESDB_PORT=5432" `
    --set-env-vars="DB_POSTGRESDB_DATABASE=$DB_NAME" `
    --set-env-vars="DB_POSTGRESDB_USER=$DB_USER" `
    --set-env-vars="DB_POSTGRESDB_PASSWORD=$DB_PASSWORD" `
    --set-env-vars="NODE_ENV=production"

Write-Host "=== Obteniendo URL del servicio ===" -ForegroundColor Green
$SERVICE_URL = gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)"
Write-Host "URL del servicio: $SERVICE_URL" -ForegroundColor Yellow

Write-Host "=== Actualizando configuración con URL del servicio ===" -ForegroundColor Green
gcloud run services update $SERVICE_NAME `
    --region=$REGION `
    --set-env-vars="N8N_HOST=$($SERVICE_URL.Replace('https://',''))" `
    --set-env-vars="N8N_PROTOCOL=https"

Write-Host "=== Despliegue completado ===" -ForegroundColor Green
Write-Host "Accede a tu instancia de n8n en: $SERVICE_URL" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor Cyan
Write-Host "Contraseña: admin123" -ForegroundColor Cyan 