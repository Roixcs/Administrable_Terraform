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


# ============================================
# Cosmos DB
# ============================================

variable "cosmos_db" {
  description = "Configuración de Cosmos DB"
  type = object({
    create             = bool
    account_name       = string
    database_name      = string
    enable_serverless  = optional(bool, true)
    consistency_level  = optional(string, "Session")
    containers = optional(list(object({
      name           = string
      partition_keys = list(string)
      throughput     = optional(number, null)
      default_ttl    = optional(number, -1)
    })), [])
  })
  default = {
    create        = false
    account_name  = ""
    database_name = ""
  }
}

# ============================================
# Key Vault
# ============================================

variable "key_vault" {
  description = "Configuración de Key Vault"
  type = object({
    create                     = bool
    name                       = string
    sku_name                   = optional(string, "standard")
    soft_delete_retention_days = optional(number, 7)
    purge_protection_enabled   = optional(bool, false)
    enable_rbac_authorization  = optional(bool, true)
  })
  default = {
    create = false
    name   = ""
  }
}

# ============================================
# API Management
# ============================================

variable "api_management" {
  description = "Configuración de API Management"
  type = object({
    create          = bool
    name            = string
    publisher_name  = string
    publisher_email = string
    sku_name        = optional(string, "Consumption_0")
  })
  default = {
    create          = false
    name            = ""
    publisher_name  = ""
    publisher_email = ""
  }
}

# ============================================
# SignalR Service
# ============================================

variable "signalr" {
  description = "Configuración de SignalR Service"
  type = object({
    create       = bool
    name         = string
    sku          = optional(string, "Free_F1")
    capacity     = optional(number, 1)
    service_mode = optional(string, "Default")
  })
  default = {
    create = false
    name   = ""
  }
}

# ============================================
# VNET VARIABLES
# ============================================

variable "vnet" {
  description = "Configuración de Virtual Network"
  type = object({
    create        = bool
    name          = string
    address_space = list(string)
    dns_servers   = optional(list(string), [])
    subnets = optional(map(object({
      name             = string
      address_prefixes = list(string)
      service_endpoints = optional(list(string), [])
      delegation = optional(object({
        name = string
        service_delegation = object({
          name    = string
          actions = optional(list(string), [])
        })
      }))
      private_endpoint_network_policies_enabled     = optional(bool, true)
      private_link_service_network_policies_enabled = optional(bool, true)
    })), {})
  })
  default = {
    create        = false
    name          = ""
    address_space = []
    dns_servers   = []
    subnets       = {}
  }
}


# ============================================
# LOG ANALYTICS WORKSPACE VARIABLES
# ============================================

variable "log_analytics" {
  description = "Configuración de Log Analytics Workspace"
  type = object({
    create                             = bool
    name                               = string
    sku                                = optional(string, "PerGB2018")
    retention_in_days                  = optional(number, 30)
    daily_quota_gb                     = optional(number, -1)
    internet_ingestion_enabled         = optional(bool, true)
    internet_query_enabled             = optional(bool, true)
    reservation_capacity_in_gb_per_day = optional(number, null)
  })
  default = {
    create = false
    name   = ""
  }
}


# ============================================
# FRONT DOOR VARIABLES
# ============================================

variable "front_door" {
  description = "Configuración de Azure Front Door"
  type = object({
    create                   = bool
    name                     = string
    sku_name                 = optional(string, "Standard_AzureFrontDoor")
    response_timeout_seconds = optional(number, 120)
    
    endpoints = optional(map(object({
      name    = string
      enabled = optional(bool, true)
    })), {})
    
    origin_groups = optional(map(object({
      name                     = string
      session_affinity_enabled = optional(bool, false)
      
      load_balancing = optional(object({
        additional_latency_in_milliseconds = optional(number, 50)
        sample_size                        = optional(number, 4)
        successful_samples_required        = optional(number, 3)
      }), {})
      
      health_probe = optional(object({
        interval_in_seconds = number
        path                = optional(string, "/")
        protocol            = string
        request_type        = optional(string, "HEAD")
      }))
    })), {})
    
    origins = optional(map(object({
      name                           = string
      origin_group_key              = string
      host_name                      = string
      http_port                      = optional(number, 80)
      https_port                     = optional(number, 443)
      certificate_name_check_enabled = optional(bool, true)
      enabled                        = optional(bool, true)
      priority                       = optional(number, 1)
      weight                         = optional(number, 1000)
      
      private_link = optional(object({
        request_message        = optional(string)
        target_type           = optional(string)
        location              = string
        private_link_target_id = string
      }))
    })), {})
    
    routes = optional(map(object({
      name                   = string
      endpoint_key           = string
      origin_group_key       = string
      origin_keys            = list(string)
      patterns_to_match      = list(string)
      supported_protocols    = list(string)
      forwarding_protocol    = optional(string, "HttpsOnly")
      https_redirect_enabled = optional(bool, true)
      enabled                = optional(bool, true)
      link_to_default_domain = optional(bool, true)
      
      cache = optional(object({
        query_string_caching_behavior = optional(string, "IgnoreQueryString")
        query_strings                 = optional(list(string), [])
        compression_enabled           = optional(bool, true)
        content_types_to_compress     = optional(list(string), [])
      }))
      
      custom_domains = optional(list(string), [])
    })), {})
    
    custom_domains = optional(map(object({
      name      = string
      host_name = string
      
      tls = optional(object({
        certificate_type    = optional(string, "ManagedCertificate")
        minimum_tls_version = optional(string, "TLS12")
      }), {
        certificate_type    = "ManagedCertificate"
        minimum_tls_version = "TLS12"
      })
    })), {})
  })
  
  default = {
    create   = false
    name     = ""
    sku_name = "Standard_AzureFrontDoor"
  }
}


# ============================================
# AZURE FUNCTIONS (WINDOWS) VARIABLES
# ============================================

variable "functions_windows" {
  description = "Configuración de Azure Functions Windows"
  type = list(object({
    name        = string
    plan_type   = string  # "consumption" o "basic"
    create      = bool
    plan_name   = optional(string)
    
    app_settings = optional(list(object({
      name         = string
      value        = string
      slot_setting = optional(bool, false)
    })), [])
    
    always_on                     = optional(bool, false)
    dotnet_version                = optional(string, "v8.0")
    use_dotnet_isolated_runtime   = optional(bool, true)
    
    vnet_integration = optional(object({
      subnet_id = string
    }))
    
    identity_type                  = optional(string, "SystemAssigned")
    identity_ids                   = optional(list(string), [])
    application_insights_enabled   = optional(bool, true)
    storage_account_name           = optional(string)
    storage_uses_managed_identity  = optional(bool, false)
  }))
  default = []
}