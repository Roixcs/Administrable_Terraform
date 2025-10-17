# ============================================
# Storage Account Module - Variables
# ============================================
# Este módulo es para Storage Accounts INDEPENDIENTES:
# 1. Static Website (para Front Door)
# 2. Storage V2 genérico (blobs, tables, queues)
# ============================================

variable "name" {
  description = "Nombre del Storage Account (debe ser único globalmente, 3-24 caracteres, solo lowercase y números)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "El nombre debe tener 3-24 caracteres, solo letras minúsculas y números."
  }
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "location" {
  description = "Location de Azure"
  type        = string
}

variable "account_tier" {
  description = "Tier del Storage Account (Standard o Premium)"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier debe ser Standard o Premium."
  }
}

variable "account_replication_type" {
  description = "Tipo de replicación (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Tipo de replicación inválido."
  }
}

variable "storage_type" {
  description = "Tipo de storage: 'static_website' o 'general'"
  type        = string
  
  validation {
    condition     = contains(["static_website", "general"], var.storage_type)
    error_message = "storage_type debe ser 'static_website' o 'general'."
  }
}

variable "enable_https_traffic_only" {
  description = "Permitir solo tráfico HTTPS"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Versión mínima de TLS"
  type        = string
  default     = "TLS1_2"
}

variable "index_document" {
  description = "Documento index para Static Website (solo si storage_type = 'static_website')"
  type        = string
  default     = "index.html"
}

variable "error_404_document" {
  description = "Documento 404 para Static Website (solo si storage_type = 'static_website')"
  type        = string
  default     = "404.html"
}

variable "tags" {
  description = "Tags para el Storage Account"
  type        = map(string)
  default     = {}
}