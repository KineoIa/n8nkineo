# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Cambiar a usuario root temporalmente para configuración
USER root

# Instalar curl para healthcheck si no está disponible
RUN apk add --no-cache curl

# Volver al usuario node
USER node

# Establecer variables de entorno para Cloud Run
ENV NODE_ENV=production
ENV N8N_PROTOCOL=https
ENV PORT=8080
ENV N8N_PORT=8080
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV N8N_HOST=0.0.0.0
ENV N8N_BASIC_AUTH_ACTIVE=false

# Crear directorio para datos si no existe
RUN mkdir -p /home/node/.n8n

# Exponer puerto 8080 (estándar de Cloud Run)
EXPOSE 8080

# Healthcheck para verificar que n8n está funcionando
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/healthz || exit 1

# Usar el comando por defecto de n8n
CMD ["n8n", "start"] 