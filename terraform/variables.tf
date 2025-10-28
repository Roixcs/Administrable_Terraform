# # ============================================
# # Root Variables
# # ============================================

# # ============================================
# # Global
# # ============================================

# variable "project_name" {
#   description = "Nombre del proyecto/cliente"
#   type        = string

#   validation {
#     condition     = can(regex("^[a-z0-9-]+$", var.project_name))
#     error_message = "project_name solo puede contener letras minúsculas, números y guiones."
#   }
# }

# variable "environment" {
#   description = "Ambiente (dev, uat, prd)"
#   type        = string

#   validation {
#     condition     = contains(["dev", "uat", "prd"], var.environment)
#     error_message = "environment debe ser: dev, uat o prd."
#   }
# }

# variable "location" {
#   description = "Location de Azure"
#   type        = string
#   default     = "East US"
# }

# variable "tags" {
#   description = "Tags comunes para todos los recursos"
#   type        = map(string)
#   default     = {}
# }

# # ============================================
# # Azure Authentication
# # ============================================

# variable "subscription_id" {
#   description = "Azure Subscription ID"
#   type        = string
#   sensitive   = true
# }

# variable "tenant_id" {
#   description = "Azure Tenant ID"
#   type        = string
#   sensitive   = true
# }

# variable "client_id" {
#   description = "Service Principal Client ID"
#   type        = string
#   sensitive   = true
# }

# variable "client_secret" {
#   description = "Service Principal Client Secret"
#   type        = string
#   sensitive   = true
# }

# # ============================================
# # Resource Group
# # ============================================

# variable "resource_group" {
#   description = "Configuración del Resource Group"
#   type = object({
#     create = bool
#     name   = string
#   })

#   validation {
#     condition     = var.resource_group.name != ""
#     error_message = "El nombre del Resource Group no puede estar vacío."
#   }
# }


# # ============================================
# # Application Insights Workspace
# # ============================================

# variable "application_insights" {
#   description = "Configuración de Application Insights"
#   type = object({
#     create_workspace = optional(bool, true)
#     workspace_name   = optional(string, "")
#   })
#   default = {
#     create_workspace = true
#   }
# }


# # ============================================
# # LOG ANALYTICS WORKSPACE VARIABLES
# # ============================================

# variable "log_analytics" {
#   description = "Configuración de Log Analytics Workspace"
#   type = object({
#     create                             = bool
#     name                               = string
#     sku                                = optional(string, "PerGB2018")
#     retention_in_days                  = optional(number, 30)
#     daily_quota_gb                     = optional(number, -1)
#     internet_ingestion_enabled         = optional(bool, true)
#     internet_query_enabled             = optional(bool, true)
#     reservation_capacity_in_gb_per_day = optional(number, null)
#   })
#   default = {
#     create = false
#     name   = ""
#   }
# }


# # ============================================
# # Azure Functions Linux
# # ============================================

# variable "functions_linux" {
#   description = "Lista de Azure Functions Linux (Flex Consumption)"
#   type = list(object({
#     name    = string
#     runtime = optional(string, "dotnet-isolated")
#     version = optional(string, "8.0")
#     app_settings = optional(list(object({
#       name         = string
#       value        = string
#       slot_setting = optional(bool, false)
#     })), [])
#     instance_memory_mb     = optional(number, 2048)
#     maximum_instance_count = optional(number, 100)
#   }))
#   default = []
# }


# # ============================================
# # Azure Functions Windows
# # ============================================

# variable "functions_windows" {
#   description = "Lista de Azure Functions Windows"
#   type = list(object({
#     name      = string
#     enabled   = optional(bool, true)
#     plan_type = string # "consumption" o "basic"
#     plan_name = optional(string)

#     app_settings = optional(list(object({
#       name         = string
#       value        = string
#       slot_setting = optional(bool, false)
#     })), [])

#     always_on                   = optional(bool, false)
#     dotnet_version              = optional(string, "v8.0")
#     use_dotnet_isolated_runtime = optional(bool, true)

#     vnet_integration = optional(object({
#       subnet_id = string
#     }))

#     identity_type                 = optional(string, "SystemAssigned")
#     identity_ids                  = optional(list(string), [])
#     application_insights_enabled  = optional(bool, true)
#     storage_account_name          = optional(string)
#     storage_uses_managed_identity = optional(bool, false)
#   }))
#   default = []
# }

# # ============================================
# # Service Bus
# # ============================================

# variable "service_bus" {
#   description = "Configuración del Service Bus"
#   type = object({
#     namespace_name = string
#     sku            = optional(string, "Standard")
#     queues = optional(list(object({
#       name                                        = string
#       enabled                                     = optional(bool, true)
#       max_size_in_megabytes                       = optional(number, 1024)
#       enable_dead_lettering_on_message_expiration = optional(bool, true)
#       max_delivery_count                          = optional(number, 10)
#       duplicate_detection_history_time_window     = optional(string, "PT10M")
#       enable_batched_operations                   = optional(bool, true)
#     })), [])
#     topics = optional(list(object({
#       name                                    = string
#       enabled                                 = optional(bool, true)
#       max_size_in_megabytes                   = optional(number, 1024)
#       duplicate_detection_history_time_window = optional(string, "PT10M")
#       enable_batched_operations               = optional(bool, true)
#       subscriptions = optional(list(object({
#         name                                        = string
#         enabled                                     = optional(bool, true)
#         max_delivery_count                          = optional(number, 10)
#         enable_dead_lettering_on_message_expiration = optional(bool, true)
#       })), [])
#     })), [])
#   })
# }


# # ============================================
# # Storage Accounts (INDEPENDIENTES - no para Functions)
# # ============================================

# variable "storage_accounts" {
#   description = "Storage Accounts independientes (Static Website o V2 general)"
#   type = list(object({
#     name                     = string
#     storage_type             = string # "static_website" o "general"
#     account_tier             = optional(string, "Standard")
#     account_replication_type = optional(string, "LRS")
#     access_tier              = optional(string, "Hot")

#     enable_https_traffic_only = optional(bool, true)
#     min_tls_version           = optional(string, "TLS1_2")

#     # Static Website
#     index_document     = optional(string, "index.html")
#     error_404_document = optional(string, "404.html")

#     # Containers
#     containers = optional(list(object({
#       name        = string
#       access_type = optional(string, "private")
#     })), [])

#     # Lifecycle Management
#     lifecycle_rules = optional(list(object({
#       name                       = string
#       enabled                    = optional(bool, true)
#       prefix_match               = optional(list(string), [])
#       blob_types                 = optional(list(string), ["blockBlob"])
#       tier_to_cool_after_days    = optional(number, null)
#       tier_to_archive_after_days = optional(number, null)
#       delete_after_days          = optional(number, null)
#     })), [])
#   }))
#   default = []

#   validation {
#     condition = alltrue([
#       for sa in var.storage_accounts : contains(["static_website", "general"], sa.storage_type)
#     ])
#     error_message = "storage_type debe ser 'static_website' o 'general'."
#   }
# }

# # ============================================
# # Cosmos DB
# # ============================================

# variable "cosmos_db" {
#   description = "Configuración de Cosmos DB"
#   type = object({
#     create            = bool
#     account_name      = string
#     database_name     = string
#     enable_serverless = optional(bool, true)
#     consistency_level = optional(string, "Session")
#     containers = optional(list(object({
#       name           = string
#       partition_keys = list(string)
#       throughput     = optional(number, null)
#       default_ttl    = optional(number, -1)
#     })), [])

#     # Network Configuration
#     public_network_access_enabled = optional(bool, true)
#     ip_range_filter               = optional(list(string), [])
#     virtual_network_rules = optional(list(object({
#       subnet_id               = string
#       ignore_missing_endpoint = optional(bool, false)
#     })), [])
#     enable_private_endpoint    = optional(bool, false)
#     private_endpoint_subnet_id = optional(string, null)
#   })
#   default = {
#     create        = false
#     account_name  = ""
#     database_name = ""
#   }
# }


# # ============================================
# # Key Vault
# # ============================================

# variable "key_vault" {
#   description = "Configuración de Key Vault"
#   type = object({
#     create                     = bool
#     name                       = string
#     sku_name                   = optional(string, "standard")
#     soft_delete_retention_days = optional(number, 7)
#     purge_protection_enabled   = optional(bool, false)
#     enable_rbac_authorization  = optional(bool, true)

#     # Permisos para servicios Azure
#     enabled_for_deployment          = optional(bool, false)
#     enabled_for_disk_encryption     = optional(bool, false)
#     enabled_for_template_deployment = optional(bool, false)

#     # Network ACLs
#     network_acls = optional(object({
#       default_action = optional(string, "Allow")
#       bypass         = optional(string, "AzureServices")
#       ip_rules       = optional(list(string), [])
#       }), {
#       default_action = "Allow"
#       bypass         = "AzureServices"
#     })

#     # Secretos a crear (opcional)
#     secrets = optional(list(object({
#       name  = string
#       value = string
#     })), [])
#   })
#   default = {
#     create = false
#     name   = ""
#   }
# }

# # ============================================
# # API Management
# # ============================================

# variable "api_management" {
#   description = "Configuración de API Management"
#   type = object({
#     create          = bool
#     name            = string
#     publisher_name  = string
#     publisher_email = string
#     sku_name        = optional(string, "Consumption_0")

#     # VNet Configuration (solo para non-Consumption SKUs)
#     virtual_network_type = optional(string, "None")
#     virtual_network_configuration = optional(object({
#       subnet_id = string
#     }), null)
#     public_ip_address_id = optional(string, null)
#   })
#   default = {
#     create          = false
#     name            = ""
#     publisher_name  = ""
#     publisher_email = ""
#   }
# }

# # ============================================
# # SignalR Service
# # ============================================

# variable "signalr" {
#   description = "Configuración de SignalR Service"
#   type = object({
#     create       = bool
#     name         = string
#     sku          = optional(string, "Free_F1")
#     capacity     = optional(number, 1)
#     service_mode = optional(string, "Default")

#     # CORS
#     cors_allowed_origins = optional(list(string), ["*"])

#     # Network
#     public_network_access_enabled = optional(bool, true)
#   })
#   default = {
#     create = false
#     name   = ""
#   }
# }



# # ============================================
# # Virtual Network
# # ============================================

# variable "vnet" {
#   description = "Configuración de Virtual Network"
#   type = object({
#     create_vnet         = bool
#     vnet_name           = string
#     resource_group_name = optional(string, null) # Si es null, usa el RG del proyecto
#     address_space       = optional(list(string), [])
#     dns_servers         = optional(list(string), [])

#     subnets = optional(map(object({
#       name              = string
#       address_prefixes  = list(string)
#       service_endpoints = optional(list(string), [])

#       delegation = optional(object({
#         name = string
#         service_delegation = object({
#           name    = string
#           actions = optional(list(string), [])
#         })
#       }))

#       private_endpoint_network_policies_enabled     = optional(bool, true)
#       private_link_service_network_policies_enabled = optional(bool, true)
#     })), {})
#   })
#   default = {
#     create_vnet = false
#     vnet_name   = ""
#     subnets     = {}
#   }
# }


# # ============================================
# # FRONT DOOR VARIABLES
# # ============================================

# variable "front_door" {
#   description = "Configuración de Azure Front Door"
#   type = object({
#     create                   = bool
#     name                     = string
#     sku_name                 = optional(string, "Standard_AzureFrontDoor")
#     response_timeout_seconds = optional(number, 120)

#     endpoints = optional(map(object({
#       name    = string
#       enabled = optional(bool, true)
#     })), {})

#     origin_groups = optional(map(object({
#       name                     = string
#       session_affinity_enabled = optional(bool, false)

#       load_balancing = optional(object({
#         additional_latency_in_milliseconds = optional(number, 50)
#         sample_size                        = optional(number, 4)
#         successful_samples_required        = optional(number, 3)
#       }), {})

#       health_probe = optional(object({
#         interval_in_seconds = number
#         path                = optional(string, "/")
#         protocol            = string
#         request_type        = optional(string, "HEAD")
#       }))
#     })), {})

#     origins = optional(map(object({
#       name                           = string
#       origin_group_key               = string
#       host_name                      = string
#       http_port                      = optional(number, 80)
#       https_port                     = optional(number, 443)
#       certificate_name_check_enabled = optional(bool, true)
#       enabled                        = optional(bool, true)
#       priority                       = optional(number, 1)
#       weight                         = optional(number, 1000)

#       private_link = optional(object({
#         request_message        = optional(string)
#         target_type            = optional(string)
#         location               = string
#         private_link_target_id = string
#       }))
#     })), {})

#     routes = optional(map(object({
#       name                   = string
#       endpoint_key           = string
#       origin_group_key       = string
#       origin_keys            = list(string)
#       patterns_to_match      = list(string)
#       supported_protocols    = list(string)
#       forwarding_protocol    = optional(string, "HttpsOnly")
#       https_redirect_enabled = optional(bool, true)
#       enabled                = optional(bool, true)
#       link_to_default_domain = optional(bool, true)

#       cache = optional(object({
#         query_string_caching_behavior = optional(string, "IgnoreQueryString")
#         query_strings                 = optional(list(string), [])
#         compression_enabled           = optional(bool, true)
#         content_types_to_compress     = optional(list(string), [])
#       }))

#       custom_domains = optional(list(string), [])
#       rule_set_keys  = optional(list(string), [])
#     })), {})

#     custom_domains = optional(map(object({
#       name      = string
#       host_name = string

#       tls = optional(object({
#         certificate_type    = optional(string, "ManagedCertificate")
#         minimum_tls_version = optional(string, "TLS12")
#         }), {
#         certificate_type    = "ManagedCertificate"
#         minimum_tls_version = "TLS12"
#       })
#     })), {})

#     rule_sets = optional(map(object({
#       name = string
#     })), {})

#     rules = optional(map(object({
#       name              = string
#       rule_set_key      = string
#       order             = number
#       behavior_on_match = optional(string, "Continue")

#       conditions = optional(object({
#         request_uri = optional(object({
#           operator         = string
#           match_values     = optional(list(string), [])
#           negate_condition = optional(bool, false)
#           transforms       = optional(list(string), [])
#         }))

#         url_path = optional(object({
#           operator         = string
#           match_values     = optional(list(string), [])
#           negate_condition = optional(bool, false)
#           transforms       = optional(list(string), [])
#         }))

#         url_file_extension = optional(object({
#           operator         = string
#           match_values     = list(string)
#           negate_condition = optional(bool, false)
#           transforms       = optional(list(string), [])
#         }))
#       }))

#       actions = object({
#         url_rewrite = optional(object({
#           source_pattern          = string
#           destination             = string
#           preserve_unmatched_path = optional(bool, false)
#         }))

#         url_redirect = optional(object({
#           redirect_type        = string
#           redirect_protocol    = optional(string, "Https")
#           destination_hostname = optional(string)
#           destination_path     = optional(string)
#           query_string         = optional(string)
#           destination_fragment = optional(string)
#         }))

#         response_headers = optional(map(object({
#           action = string
#           value  = optional(string)
#         })), {})

#         request_headers = optional(map(object({
#           action = string
#           value  = optional(string)
#         })), {})
#       })
#     })), {})
#   })

#   default = {
#     create   = false
#     name     = ""
#     sku_name = "Standard_AzureFrontDoor"
#   }
# }



# ============================================
# ROOT - Variables Definition
# ============================================

# ============================================
# Global Configuration
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
# Application Insights & Log Analytics
# ============================================

variable "application_insights" {
  description = "Configuración de Application Insights Workspace"
  type = object({
    create_workspace = bool
    workspace_name   = optional(string, null)
  })
  default = {
    create_workspace = true
    workspace_name   = null
  }
}

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
# Storage Accounts (INDEPENDIENTES)
# ============================================

variable "storage_accounts" {
  description = "Storage Accounts independientes (Static Website o V2 general)"
  type = list(object({
    name                     = string
    storage_type             = string # "static_website" o "general"
    account_tier             = optional(string, "Standard")
    account_replication_type = optional(string, "LRS")
    access_tier              = optional(string, "Hot")

    enable_https_traffic_only = optional(bool, true)
    min_tls_version           = optional(string, "TLS1_2")

    # Static Website
    index_document     = optional(string, "index.html")
    error_404_document = optional(string, "404.html")

    # Containers
    containers = optional(list(object({
      name        = string
      access_type = optional(string, "private")
    })), [])

    # Lifecycle Management
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
  default = []

  validation {
    condition = alltrue([
      for sa in var.storage_accounts : contains(["static_website", "general"], sa.storage_type)
    ])
    error_message = "storage_type debe ser 'static_website' o 'general'."
  }
}

# ============================================
# Service Bus
# ============================================

variable "service_bus" {
  description = "Configuración de Service Bus"
  type = object({
    create         = bool
    namespace_name = string
    sku            = optional(string, "Standard")

    queues = optional(list(object({
      name                                    = string
      enabled                                 = optional(bool, true)
      max_size_in_megabytes                   = optional(number, 1024)
      duplicate_detection_history_time_window = optional(string, "PT10M")
      enable_batched_operations               = optional(bool, true)
    })), [])

    topics = optional(list(object({
      name                                    = string
      enabled                                 = optional(bool, true)
      max_size_in_megabytes                   = optional(number, 1024)
      duplicate_detection_history_time_window = optional(string, "PT10M")
      enable_batched_operations               = optional(bool, true)
      subscriptions = optional(list(object({
        name                                        = string
        enabled                                     = optional(bool, true)
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
# Cosmos DB
# ============================================

variable "cosmos_db" {
  description = "Configuración de Cosmos DB"
  type = object({
    create            = bool
    account_name      = string
    database_name     = string
    enable_serverless = optional(bool, true)
    consistency_level = optional(string, "Session")

    containers = optional(list(object({
      name               = string
      partition_key_path = string
      throughput         = optional(number, null)
    })), [])

    public_network_access_enabled = optional(bool, true)
    ip_range_filter               = optional(list(string), [])
    virtual_network_rules = optional(list(object({
      subnet_id               = string
      ignore_missing_endpoint = optional(bool, false)
    })), [])
    enable_private_endpoint    = optional(bool, false)
    private_endpoint_subnet_id = optional(string, null)
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

    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)

    network_acls = optional(object({
      default_action             = optional(string, "Allow")
      bypass                     = optional(string, "AzureServices")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
      }), {
      default_action = "Allow"
      bypass         = "AzureServices"
    })

    secrets = optional(list(object({
      name  = string
      value = string
    })), [])
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
    sku_name        = optional(string, "Developer_1")

    virtual_network_type = optional(string, "None")
    virtual_network_configuration = optional(object({
      subnet_id = string
    }), null)
    public_ip_address_id = optional(string, null)
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
    create                        = bool
    name                          = string
    sku                           = optional(string, "Free_F1")
    capacity                      = optional(number, 1)
    service_mode                  = optional(string, "Default")
    cors_allowed_origins          = optional(list(string), ["*"])
    public_network_access_enabled = optional(bool, true)
  })
  default = {
    create = false
    name   = ""
  }
}

# ============================================
# Virtual Network
# ============================================

variable "vnet" {
  description = "Configuración de Virtual Network"
  type = object({
    create_vnet         = bool
    vnet_name           = string
    resource_group_name = optional(string, null)
    address_space       = list(string)
    dns_servers         = optional(list(string), [])
    subnets = optional(map(object({
      name              = string
      address_prefixes  = list(string)
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
    create_vnet   = false
    vnet_name     = ""
    address_space = []
  }
}

# ============================================
# Azure Functions Linux
# ============================================

variable "functions_linux" {
  description = "Lista de Azure Functions Linux (Flex Consumption)"
  type = list(object({
    name    = string
    runtime = string
    version = string

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
# Azure Functions Windows
# ============================================

variable "functions_windows" {
  description = "Lista de Azure Functions Windows"
  type = list(object({
    name      = string
    plan_type = string
    create    = bool
    plan_name = optional(string)

    app_settings = optional(list(object({
      name         = string
      value        = string
      slot_setting = optional(bool, false)
    })), [])

    always_on                   = optional(bool, false)
    dotnet_version              = optional(string, "v8.0")
    use_dotnet_isolated_runtime = optional(bool, true)

    vnet_integration = optional(object({
      subnet_id = string
    }))

    identity_type                = optional(string, "SystemAssigned")
    identity_ids                 = optional(list(string), [])
    application_insights_enabled = optional(bool, true)

    storage_account_name          = optional(string)
    storage_uses_managed_identity = optional(bool, false)
  }))
  default = []
}

# ============================================
# Front Door
# ============================================



variable "front_door" {
  description = "Configuración de Azure Front Door"
  type = object({
    create                   = bool
    name                     = string
    sku_name                 = optional(string, "Standard_AzureFrontDoor")
    response_timeout_seconds = optional(number, 120)

    # ✅ TODOS COMO MAP (no list)
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
      origin_group_key               = string
      host_name                      = string
      http_port                      = optional(number, 80)
      https_port                     = optional(number, 443)
      certificate_name_check_enabled = optional(bool, true)
      enabled                        = optional(bool, true)
      priority                       = optional(number, 1)
      weight                         = optional(number, 1000)

      private_link = optional(object({
        request_message        = optional(string)
        target_type            = optional(string)
        location               = string
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
      rule_set_keys  = optional(list(string), [])
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

    rule_sets = optional(map(object({
      name = string
    })), {})

    rules = optional(map(object({
      name              = string
      rule_set_key      = string
      order             = number
      behavior_on_match = optional(string, "Continue")

      conditions = optional(object({
        request_uri = optional(object({
          operator         = string
          match_values     = optional(list(string), [])
          negate_condition = optional(bool, false)
          transforms       = optional(list(string), [])
        }))

        url_path = optional(object({
          operator         = string
          match_values     = optional(list(string), [])
          negate_condition = optional(bool, false)
          transforms       = optional(list(string), [])
        }))

        url_file_extension = optional(object({
          operator         = string
          match_values     = list(string)
          negate_condition = optional(bool, false)
          transforms       = optional(list(string), [])
        }))
      }))

      actions = object({
        url_rewrite = optional(object({
          source_pattern          = string
          destination             = string
          preserve_unmatched_path = optional(bool, false)
        }))

        url_redirect = optional(object({
          redirect_type        = string
          redirect_protocol    = optional(string, "Https")
          destination_hostname = optional(string)
          destination_path     = optional(string)
          query_string         = optional(string)
          destination_fragment = optional(string)
        }))

        response_headers = optional(map(object({
          action = string
          value  = optional(string)
        })), {})

        request_headers = optional(map(object({
          action = string
          value  = optional(string)
        })), {})
      })
    })), {})
  })

  default = {
    create = false
    name   = ""
  }
}
