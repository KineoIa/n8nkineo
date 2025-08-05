# Desplegar n8n en Google Cloud Run

## Prerequisitos

1. **Google Cloud CLI instalado**: [Descargar aquí](https://cloud.google.com/sdk/docs/install)
2. **Proyecto de Google Cloud activo** con facturación habilitada
3. **Permisos de Cloud Run y Cloud SQL** en el proyecto

## Configuración inicial

1. **Instalar y configurar gcloud CLI**:
   ```powershell
   gcloud auth login
   gcloud config set project TU-PROJECT-ID
   ```

2. **Modificar variables en el script**:
   - Edita `deploy-cloudrun.ps1`
   - Cambia `$PROJECT_ID` por tu ID de proyecto de GCP
   - Ajusta región, nombres y contraseñas según tus preferencias

## Despliegue

### Opción A: Usar el script automatizado
```powershell
.\deploy-cloudrun.ps1
```

### Opción B: Comandos manuales

1. **Habilitar APIs**:
   ```powershell
   gcloud services enable run.googleapis.com sqladmin.googleapis.com
   ```

2. **Crear Cloud SQL**:
   ```powershell
   gcloud sql instances create n8n-db-instance --database-version=POSTGRES_13 --tier=db-f1-micro --region=us-central1
   gcloud sql databases create n8n --instance=n8n-db-instance
   gcloud sql users create n8n_user --instance=n8n-db-instance --password=SecurePassword123!
   ```

3. **Desplegar Cloud Run**:
   ```powershell
   gcloud run deploy n8n-service --image=n8nio/n8n --platform=managed --region=us-central1 --allow-unauthenticated --port=5678 --memory=2Gi --cpu=1
   ```

## Alternativas de base de datos

### 1. SQLite (No recomendado para producción)
Si quieres usar SQLite temporal:
```powershell
# Solo para pruebas - los datos se perderán al reiniciar
gcloud run deploy n8n-service --image=n8nio/n8n --set-env-vars="N8N_BASIC_AUTH_ACTIVE=true,N8N_BASIC_AUTH_USER=admin,N8N_BASIC_AUTH_PASSWORD=admin123"
```

### 2. MySQL en Cloud SQL
```powershell
gcloud sql instances create n8n-mysql --database-version=MYSQL_8_0 --tier=db-f1-micro --region=us-central1
# Luego usar DB_TYPE=mysqldb en las variables de entorno
```

## Consideraciones importantes

### Costos estimados (región us-central1):
- **Cloud Run**: ~$0.0048/hora con 1 CPU, 2GB RAM
- **Cloud SQL (f1-micro)**: ~$7.67/mes
- **Tráfico**: $0.12/GB (egress)

### Limitaciones:
- **Sin persistencia local**: Los archivos se pierden al reiniciar
- **Cold starts**: Puede haber latencia en el primer request
- **Timeout máximo**: 15 minutos por request

### Seguridad:
- Cambia las credenciales por defecto
- Considera usar Cloud Secret Manager para contraseñas
- Configura Cloud Armor para protección DDoS

## Monitoreo

Ver logs:
```powershell
gcloud logs tail projects/TU-PROJECT-ID/logs/run.googleapis.com%2Frequests --format="table(timestamp,severity,textPayload)"
```

Ver métricas:
```powershell
gcloud run services describe n8n-service --region=us-central1
```

## Troubleshooting

### Error de conexión a base de datos:
1. Verificar que Cloud SQL esté corriendo
2. Verificar que las variables de entorno sean correctas
3. Verificar conectividad de red

### Servicio no responde:
1. Verificar logs: `gcloud logs tail`
2. Verificar recursos asignados (CPU/memoria)
3. Verificar timeout configurado

## Backup y recuperación

### Backup automático de Cloud SQL:
```powershell
gcloud sql instances patch n8n-db-instance --backup-start-time=03:00
```

### Backup manual:
```powershell
gcloud sql backups create --instance=n8n-db-instance
```

## Escalamiento

### Configurar autoescalado:
```powershell
gcloud run services update n8n-service --min-instances=1 --max-instances=10 --concurrency=80
``` 