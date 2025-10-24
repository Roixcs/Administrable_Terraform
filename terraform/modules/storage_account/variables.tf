# ============================================
# Storage Account Module - Variables
# DISPATCHER
# ============================================

variable "storage_accounts" {
  description = "Lista de Storage Accounts a crear"
  type = list(object({
    name                     = string
    storage_type             = string  # "static_website" o "general"
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    access_tier              = optional(string, "Hot")
    
    # Seguridad
    enable_https_traffic_only = optional(bool, true)
    min_tls_version           = optional(string, "TLS1_2")
    
    # Static Website (solo si storage_type = "static_website")
    index_document     = optional(string, "index.html")
    error_404_document = optional(string, "404.html")
    
    # Containers (opcional)
    containers = optional(list(object({
      name        = string
      access_type = optional(string, "private")  # private, blob, container
    })), [])
    
    # Lifecycle Management (opcional)
    lifecycle_rules = optional(list(object({
      name                       = string
      enabled                    = optional(bool, true)
      prefix_match               = optional(list(string), [])
      blob_types                 = optional(list(string), ["blockBlob"])
      tier_to_cool_after_days    = optional(number, null)
      tier_to_archive_after_days = optional(number, null)
      delete_after_days          = optional(number, null)
    })), [])
  }))
  
  validation {
    condition = alltrue([
      for sa in var.storage_accounts : can(regex("^[a-z0-9]{3,24}$", sa.name))
    ])
    error_message = "Storage Account names must be 3-24 characters, lowercase letters and numbers only."
  }
  
  validation {
    condition = alltrue([
      for sa in var.storage_accounts : contains(["static_website", "general"], sa.storage_type)
    ])
    error_message = "storage_type must be either 'static_website' or 'general'."
  }
  
  validation {
    condition     = length(var.storage_accounts) == length(distinct([for sa in var.storage_accounts : sa.name]))
    error_message = "Storage Account names must be unique."
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

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}