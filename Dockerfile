FROM n8nio/n8n:latest

# Variables de entorno comunes
ENV N8N_HOST=0.0.0.0 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=zzadmin \
    N8N_BASIC_AUTH_PASSWORD=34355fgfe43r \
    TZ=America/Argentina/Buenos_Aires \
    N8N_EDITOR_BASE_URL=https://n8n.server0.com.ar \
    WEBHOOK_URL=https://n8n.server0.com.ar

# Expone ambos puertos por si lo necesitás para debugging, aunque Cloud Run solo usa 8080
EXPOSE 5678
EXPOSE 8080

# Script inteligente que elige el puerto según variable de entorno
CMD ["/bin/bash", "-c", "\
  PORT_TO_USE=${PORT:-5678} && \
  echo 'Iniciando n8n en el puerto' $PORT_TO_USE && \
  n8n start --port $PORT_TO_USE"]