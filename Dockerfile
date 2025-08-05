# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Establecer variables de entorno para Cloud Run
ENV NODE_ENV=production
ENV N8N_PROTOCOL=https
ENV PORT=8080
ENV N8N_PORT=8080
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Exponer puerto 8080 (estándar de Cloud Run)
EXPOSE 8080

# Usar el comando por defecto de n8n
CMD ["n8n", "start"] 