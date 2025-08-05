# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Establecer variables de entorno básicas
ENV NODE_ENV=production
ENV N8N_PROTOCOL=https

# Usar el comando por defecto de n8n
CMD ["n8n", "start"] 