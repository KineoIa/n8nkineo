terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Región para desplegar los recursos"
  type        = string
  default     = "us-central1"
}

variable "db_password" {
  description = "Contraseña para la base de datos"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Contraseña para el admin de n8n"
  type        = string
  sensitive   = true
}

# Habilitar APIs necesarias
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com"
  ])
  
  project = var.project_id
  service = each.value
}

# Crear instancia de Cloud SQL
resource "google_sql_database_instance" "n8n_postgres" {
  name             = "n8n-postgres"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    
    backup_configuration {
      enabled = true
    }
    
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"
        name  = "allow-all"
      }
    }
  }

  depends_on = [google_project_service.apis]
}

# Crear base de datos
resource "google_sql_database" "n8n_db" {
  name     = "n8n"
  instance = google_sql_database_instance.n8n_postgres.name
}

# Crear usuario de base de datos
resource "google_sql_user" "n8n_user" {
  name     = "n8n_user"
  instance = google_sql_database_instance.n8n_postgres.name
  password = var.db_password
}

# Desplegar Cloud Run service
resource "google_cloud_run_service" "n8n" {
  name     = "n8n-service"
  location = var.region

  template {
    spec {
      containers {
        image = "n8nio/n8n:latest"
        
        ports {
          container_port = 5678
        }

        env {
          name  = "N8N_BASIC_AUTH_ACTIVE"
          value = "true"
        }
        
        env {
          name  = "N8N_BASIC_AUTH_USER"
          value = "admin"
        }
        
        env {
          name  = "N8N_BASIC_AUTH_PASSWORD"
          value = var.admin_password
        }
        
        env {
          name  = "DB_TYPE"
          value = "postgresdb"
        }
        
        env {
          name  = "DB_POSTGRESDB_HOST"
          value = google_sql_database_instance.n8n_postgres.ip_address[0].ip_address
        }
        
        env {
          name  = "DB_POSTGRESDB_PORT"
          value = "5432"
        }
        
        env {
          name  = "DB_POSTGRESDB_DATABASE"
          value = "n8n"
        }
        
        env {
          name  = "DB_POSTGRESDB_USER"
          value = "n8n_user"
        }
        
        env {
          name  = "DB_POSTGRESDB_PASSWORD"
          value = var.db_password
        }
        
        env {
          name  = "N8N_PROTOCOL"
          value = "https"
        }
        
        env {
          name  = "NODE_ENV"
          value = "production"
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "2Gi"
          }
        }
      }
      
      timeout_seconds = 300
    }
  }

  depends_on = [
    google_project_service.apis,
    google_sql_database_instance.n8n_postgres
  ]
}

# Permitir acceso público
resource "google_cloud_run_service_iam_member" "public" {
  location = google_cloud_run_service.n8n.location
  project  = google_cloud_run_service.n8n.project
  service  = google_cloud_run_service.n8n.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Outputs
output "n8n_url" {
  value = google_cloud_run_service.n8n.status[0].url
}

output "database_ip" {
  value = google_sql_database_instance.n8n_postgres.ip_address[0].ip_address
} 