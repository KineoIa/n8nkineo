FROM n8nio/n8n:latest

ENV N8N_HOST=0.0.0.0 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=zzadmin \
    N8N_BASIC_AUTH_PASSWORD=34355fgfe43r \
    TZ=America/Argentina/Buenos_Aires \
    N8N_EDITOR_BASE_URL=https://n8nkineo-22290566202.europe-west1.run.app \
    WEBHOOK_URL=https://n8nkineo-22290566202.europe-west1.run.app

# Cloud Run espera que la app escuche en $PORT, por lo tanto lo seteamos así:
CMD ["sh", "-c", "n8n start --port ${PORT:-8080}"]