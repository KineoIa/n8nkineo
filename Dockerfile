# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Establecer variables de entorno básicas
ENV NODE_ENV=production
ENV N8N_PROTOCOL=https
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Crear script de inicio que use el puerto de Cloud Run
USER root
RUN echo '#!/bin/sh\nexport N8N_PORT=${PORT:-5678}\nn8n start' > /startup.sh && chmod +x /startup.sh
USER node

# Usar el script de inicio personalizado
CMD ["/startup.sh"] 