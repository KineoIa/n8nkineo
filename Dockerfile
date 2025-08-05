FROM n8nio/n8n:latest

# Variables de entorno básicas
ENV N8N_BASIC_AUTH_ACTIVE=true \
    N8N_BASIC_AUTH_USER=zzadmin \
    N8N_BASIC_AUTH_PASSWORD=34355fgfe43r \
    TZ=America/Argentina/Buenos_Aires

# Copiar script de inicio
COPY start.sh /start.sh

# Hacer ejecutable el script
USER root
RUN chmod +x /start.sh
USER node

CMD ["/start.sh"]