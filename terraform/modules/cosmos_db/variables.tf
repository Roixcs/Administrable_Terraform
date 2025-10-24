# ============================================
# Cosmos DB Module - Variables
# ============================================

variable "account_name" {
  description = "Nombre de la cuenta de Cosmos DB"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]{3,44}$", var.account_name))
    error_message = "El nombre debe tener 3-44 caracteres, solo letras minúsculas, números y guiones."
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

variable "offer_type" {
  description = "Tipo de oferta (Standard)"
  type        = string
  default     = "Standard"
}

variable "kind" {
  description = "Tipo de cuenta (GlobalDocumentDB, MongoDB, Parse)"
  type        = string
  default     = "GlobalDocumentDB"
  
  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "kind debe ser: GlobalDocumentDB, MongoDB o Parse."
  }
}

variable "consistency_level" {
  description = "Nivel de consistencia (BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix)"
  type        = string
  default     = "Session"
  
  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "consistency_level inválido."
  }
}

variable "max_interval_in_seconds" {
  description = "Max interval en segundos (solo para BoundedStaleness)"
  type        = number
  default     = 5
}

variable "max_staleness_prefix" {
  description = "Max staleness prefix (solo para BoundedStaleness)"
  type        = number
  default     = 100
}

variable "enable_serverless" {
  description = "Habilitar modo serverless"
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Habilitar backup (no disponible en serverless)"
  type        = bool
  default     = false
}

variable "backup_type" {
  description = "Tipo de backup (Periodic o Continuous)"
  type        = string
  default     = "Periodic"
}

variable "backup_interval_in_minutes" {
  description = "Intervalo de backup en minutos"
  type        = number
  default     = 240
}

variable "backup_retention_in_hours" {
  description = "Retención de backup en horas"
  type        = number
  default     = 8
}

variable "databases" {
  description = "Lista de databases y sus containers"
  type = list(object({
    name       = string
    throughput = optional(number, null)  # Throughput a nivel DB (shared), null para serverless
    
    containers = list(object({
      name           = string
      partition_keys = list(string)
      throughput     = optional(number, null)  # Throughput dedicado, null para serverless o shared
      default_ttl    = optional(number, -1)    # -1 = sin TTL, 0 = on sin default, >0 = TTL en segundos
      
      # Unique Keys
      unique_keys = optional(list(object({
        paths = list(string)
      })), [])
      
      # Indexing Policy
      indexing_policy = optional(object({
        indexing_mode   = optional(string, "consistent")
        included_paths  = optional(list(string), ["/*"])
        excluded_paths  = optional(list(string), [])
        composite_indexes = optional(list(list(object({
          path  = string
          order = string  # "ascending" o "descending"
        }))), [])
      }))
      
      # Stored Procedures
      stored_procedures = optional(list(object({
        name = string
        body = string
      })), [])
    }))
  }))
  default = []
  
  validation {
    condition = alltrue([
      for db in var.databases : length(db.containers) > 0
    ])
    error_message = "Cada database debe tener al menos un container."
  }
}

variable "tags" {
  description = "Tags para Cosmos DB"
  type        = map(string)
  default     = {}
}