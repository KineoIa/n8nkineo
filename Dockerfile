# Usa la imagen oficial de n8n
FROM n8nio/n8n:latest

# Establece variables de entorno necesarias en tiempo de construcción
ENV N8N_PORT=8080 \
    N8N_HOST=0.0.0.0 \
    N8N_LISTEN_ADDRESS=0.0.0.0 \
    N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=admin \
    N8N_BASIC_AUTH_PASSWORD=admin123 \
    N8N_EDITOR_BASE_URL=https://n8nkineo-22290566202.europe-west1.run.app \
    WEBHOOK_URL=https://n8nkineo-22290566202.europe-west1.run.app

# Exponé el puerto 8080 (Cloud Run escucha ahí)
EXPOSE 8080

# Comando por defecto para iniciar n8n
CMD ["n8n"]
