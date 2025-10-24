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

variable "database_name" {
  description = "Nombre de la base de datos"
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

variable "enable_serverless" {
  description = "Habilitar modo serverless"
  type        = bool
  default     = true
}

variable "enable_automatic_failover" {
  description = "Habilitar failover automático"
  type        = bool
  default     = false
}

variable "containers" {
  description = "Lista de containers a crear"
  type = list(object({
    name           = string
    partition_keys = list(string)
    throughput     = optional(number, null)  # null para serverless
    default_ttl    = optional(number, -1)    # -1 = sin TTL
  }))
  default = []
}

variable "tags" {
  description = "Tags para Cosmos DB"
  type        = map(string)
  default     = {}
}

# ============================================
# Network Configuration
# ============================================

variable "public_network_access_enabled" {
  description = "Habilitar acceso público a Cosmos DB"
  type        = bool
  default     = true
}

variable "ip_range_filter" {
  description = "Lista de rangos IP permitidos (CIDR o IPs individuales). Ejemplo: ['10.0.0.0/24', '20.30.40.50']"
  type        = list(string)
  default     = []
}

variable "virtual_network_rules" {
  description = "Reglas de Virtual Network para acceso a Cosmos DB"
  type = list(object({
    subnet_id                = string
    ignore_missing_endpoint = optional(bool, false)
  }))
  default = []
}

variable "enable_private_endpoint" {
  description = "Habilitar Private Endpoint para Cosmos DB"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID para Private Endpoint (requerido si enable_private_endpoint = true)"
  type        = string
  default     = null
}