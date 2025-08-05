FROM n8nio/n8n:latest

# Establecemos variables necesarias para GCP y seguridad
ENV N8N_HOST=0.0.0.0 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=zzadmin \
    N8N_BASIC_AUTH_PASSWORD=34355fgfe43r \
    TZ=America/Argentina/Buenos_Aires \
    N8N_EDITOR_BASE_URL=https://n8nkineo-22290566202.europe-west1.run.app \
    WEBHOOK_URL=https://n8nkineo-22290566202.europe-west1.run.app

# Exponemos el puerto que Cloud Run exige
EXPOSE 8080

# Usamos bash para interpretar la variable de Cloud Run PORT
CMD ["/bin/bash", "-c", "\
  echo '🟢 Iniciando n8n...'; \
  echo '📦 PORT recibido: ' $PORT; \
  PORT_TO_USE=${PORT:-8080}; \
  echo '🚀 Usando puerto:' $PORT_TO_USE; \
  n8n start --port $PORT_TO_USE"]