# ============================================
# Root Variables
# ============================================

# ============================================
# Global
# ============================================

variable "project_name" {
  description = "Nombre del proyecto/cliente"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Ambiente (dev, uat, prd)"
  type        = string
  
  validation {
    condition     = contains(["dev", "uat", "prd"], var.environment)
    error_message = "environment debe ser: dev, uat o prd."
  }
}

variable "location" {
  description = "Location de Azure"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

# ============================================
# Azure Authentication
# ============================================

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Service Principal Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Service Principal Client Secret"
  type        = string
  sensitive   = true
}

# ============================================
# Resource Group
# ============================================

variable "resource_group" {
  description = "Configuración del Resource Group"
  type = object({
    create = bool
    name   = string
  })
  
  validation {
    condition     = var.resource_group.name != ""
    error_message = "El nombre del Resource Group no puede estar vacío."
  }
}

# ============================================
# Storage Accounts (INDEPENDIENTES - no para Functions)
# ============================================

variable "storage_accounts" {
  description = "Storage Accounts independientes (Static Website o V2 general)"
  type = map(object({
    name                     = string
    storage_type             = string  # "static_website" o "general"
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.storage_accounts : contains(["static_website", "general"], v.storage_type)
    ])
    error_message = "storage_type debe ser 'static_website' o 'general'."
  }
}

# ============================================
# Service Bus
# ============================================

variable "service_bus" {
  description = "Configuración del Service Bus"
  type = object({
    create         = bool
    namespace_name = string
    sku            = optional(string, "Standard")
    queues = optional(list(object({
      name                                        = string
      max_size_in_megabytes                      = optional(number, 1024)
      enable_partitioning                        = optional(bool, false)
      enable_dead_lettering_on_message_expiration = optional(bool, true)
      max_delivery_count                         = optional(number, 10)
      duplicate_detection_history_time_window    = optional(string, "PT10M")
    })), [])
    topics = optional(list(object({
      name                  = string
      max_size_in_megabytes = optional(number, 1024)
      enable_partitioning   = optional(bool, false)
      subscriptions = optional(list(object({
        name                                        = string
        max_delivery_count                          = optional(number, 10)
        enable_dead_lettering_on_message_expiration = optional(bool, true)
      })), [])
    })), [])
  })
  default = {
    create         = false
    namespace_name = ""
  }
}

# ============================================
# Azure Functions Linux
# ============================================

variable "functions_linux" {
  description = "Azure Functions Linux (Flex Consumption)"
  type = list(object({
    name    = string
    runtime = optional(string, "dotnet-isolated")
    version = optional(string, "8.0")
    app_settings = optional(list(object({
      name         = string
      value        = string
      slot_setting = optional(bool, false)
    })), [])
    instance_memory_mb     = optional(number, 2048)
    maximum_instance_count = optional(number, 100)
  }))
  default = []
}

# ============================================
# Application Insights Workspace
# ============================================

variable "application_insights" {
  description = "Configuración de Application Insights"
  type = object({
    create_workspace = optional(bool, true)
    workspace_name   = optional(string, "")
  })
  default = {
    create_workspace = true
  }
}

