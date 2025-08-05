# Usar la imagen oficial de n8n como base
FROM n8nio/n8n:latest

# Cambiar a root para configuración
USER root

# Crear script de inicio que configure n8n para Cloud Run
RUN cat > /usr/local/bin/start-n8n.sh << 'EOF'
#!/bin/sh
# Configurar n8n para Cloud Run
export N8N_HOST=0.0.0.0
export N8N_PORT=${PORT:-8080}
export N8N_LISTEN_ADDRESS=0.0.0.0
export NODE_ENV=production
export N8N_PROTOCOL=https

echo "Starting n8n on port $N8N_PORT"
exec n8n start
EOF

# Hacer el script ejecutable
RUN chmod +x /usr/local/bin/start-n8n.sh

# Volver al usuario node
USER node

# Usar el script de inicio
CMD ["/usr/local/bin/start-n8n.sh"] 