#!/bin/sh
set -e

# Cloud Run proporciona PORT, configuramos n8n para usarlo
export N8N_PORT=${PORT:-8080}
export N8N_HOST=0.0.0.0
export N8N_LISTEN_ADDRESS=0.0.0.0

# Configuraciones específicas para Cloud Run
export N8N_EDITOR_BASE_URL=https://n8nkineo-22290566202.europe-west1.run.app
export WEBHOOK_URL=https://n8nkineo-22290566202.europe-west1.run.app
export NODE_ENV=production

echo "Starting n8n on port $N8N_PORT"
echo "Editor will be available at $N8N_EDITOR_BASE_URL"

# Ejecutar n8n
exec n8n start 