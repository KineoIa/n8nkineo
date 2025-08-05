# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Establecer variables de entorno por defecto
ENV NODE_ENV=production
ENV N8N_PROTOCOL=https

# Exponer puerto 5678
EXPOSE 5678

# Usar el comando por defecto de n8n
CMD ["n8n", "start"] 