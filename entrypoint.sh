#!/bin/bash

PORT_TO_USE=${PORT:-8080}
echo "🟢 Iniciando n8n en puerto: $PORT_TO_USE"
n8n start --port $PORT_TO_USE