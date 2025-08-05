FROM n8nio/n8n:latest

# Variables obligatorias para n8n + GCP
ENV N8N_HOST=0.0.0.0 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=zzadmin \
    N8N_BASIC_AUTH_PASSWORD=34355fgfe43r \
    TZ=America/Argentina/Buenos_Aires \
    N8N_EDITOR_BASE_URL=https://n8nkineo-22290566202.europe-west1.run.app \
    WEBHOOK_URL=https://n8nkineo-22290566202.europe-west1.run.app

# Copiamos el script y le damos permisos
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

# Usamos el entrypoint
CMD ["/entrypoint.sh"]
