#!/bin/bash

# Script para desplegar n8n en Google Cloud Run
# Asegúrate de tener gcloud CLI instalado y autenticado

# Variables de configuración
PROJECT_ID="tu-proyecto-gcp"
REGION="us-central1"
SERVICE_NAME="n8n-service"
DB_PASSWORD="tu-password-seguro"
ADMIN_PASSWORD="tu-admin-password"

echo "Desplegando n8n en Google Cloud Run..."

# 1. Configurar proyecto
gcloud config set project $PROJECT_ID

# 2. Habilitar APIs necesarias
echo "Habilitando APIs..."
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com

# 3. Crear instancia de Cloud SQL (PostgreSQL)
echo "Creando instancia de Cloud SQL..."
gcloud sql instances create n8n-postgres \
    --database-version=POSTGRES_14 \
    --tier=db-f1-micro \
    --region=$REGION \
    --root-password=$DB_PASSWORD

# 4. Crear base de datos y usuario
echo "Configurando base de datos..."
gcloud sql databases create n8n --instance=n8n-postgres
gcloud sql users create n8n_user \
    --instance=n8n-postgres \
    --password=$DB_PASSWORD

# 5. Obtener IP de Cloud SQL
DB_IP=$(gcloud sql instances describe n8n-postgres --format="value(ipAddresses[0].ipAddress)")

# 6. Desplegar en Cloud Run
echo "Desplegando servicio en Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image=n8nio/n8n:latest \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated \
    --port=5678 \
    --memory=2Gi \
    --cpu=1 \
    --timeout=300 \
    --set-env-vars="N8N_BASIC_AUTH_ACTIVE=true,N8N_BASIC_AUTH_USER=admin,N8N_BASIC_AUTH_PASSWORD=$ADMIN_PASSWORD,DB_TYPE=postgresdb,DB_POSTGRESDB_HOST=$DB_IP,DB_POSTGRESDB_PORT=5432,DB_POSTGRESDB_DATABASE=n8n,DB_POSTGRESDB_USER=n8n_user,DB_POSTGRESDB_PASSWORD=$DB_PASSWORD,N8N_PROTOCOL=https,NODE_ENV=production"

# 7. Obtener URL del servicio
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

# 8. Actualizar variable de entorno N8N_HOST
gcloud run services update $SERVICE_NAME \
    --region=$REGION \
    --set-env-vars="N8N_HOST=${SERVICE_URL#https://}"

echo "✅ Despliegue completado!"
echo "🌐 URL de n8n: $SERVICE_URL"
echo "👤 Usuario: admin"
echo "🔑 Contraseña: $ADMIN_PASSWORD" 