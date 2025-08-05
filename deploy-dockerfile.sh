#!/bin/bash

# Script para desplegar n8n usando Dockerfile local
PROJECT_ID="botkineo"
REGION="europe-west1"
SERVICE_NAME="n8nkineo"
IMAGE_NAME="n8n-custom"

echo "🚀 Desplegando n8n usando Dockerfile local..."

# 1. Configurar proyecto
gcloud config set project $PROJECT_ID

# 2. Habilitar APIs necesarias
echo "📡 Habilitando APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# 3. Crear repositorio en Artifact Registry si no existe
echo "📦 Configurando Artifact Registry..."
gcloud artifacts repositories create cloud-run-source-deploy \
    --repository-format=docker \
    --location=$REGION \
    --description="Repository for Cloud Run images" || echo "Repository may already exist"

# 4. Construir y subir imagen usando Cloud Build
echo "🔨 Construyendo imagen..."
gcloud builds submit \
    --tag $REGION-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/$IMAGE_NAME:latest \
    --project $PROJECT_ID

# 5. Desplegar en Cloud Run
echo "🚀 Desplegando en Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $REGION-docker.pkg.dev/$PROJECT_ID/cloud-run-source-deploy/$IMAGE_NAME:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 1 \
    --max-instances 5 \
    --timeout 300 \
    --port 8080

# 6. Obtener URL del servicio
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo "✅ Despliegue completado!"
echo "🌐 URL de n8n: $SERVICE_URL"
echo "ℹ️  Nota: n8n usará SQLite local (los datos se perderán al reiniciar)" 