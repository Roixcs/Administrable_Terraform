# output "resource_group_name" {
#   description = "Nombre del Resource Group"
#   value       = var.resource_group.create ? module.resource_group[0].name : var.resource_group.name
# }

# output "resource_group_id" {
#   description = "ID del Resource Group"
#   value       = var.resource_group.create ? module.resource_group[0].id : null
# }

# output "resource_group_location" {
#   description = "Location del Resource Group"
#   value       = var.resource_group.create ? module.resource_group[0].location : var.location
# }

# output "workspace_id" {
#   description = "ID del Log Analytics Workspace compartido"
#   value       = var.application_insights.create_workspace ? azurerm_log_analytics_workspace.shared[0].id : null
# }


# # ============================================
# # LOG ANALYTICS WORKSPACE OUTPUTS
# # ============================================

# output "log_analytics_id" {
#   description = "ID del Log Analytics Workspace"
#   value       = module.log_analytics.id
# }

# output "log_analytics_name" {
#   description = "Nombre del Log Analytics Workspace"
#   value       = module.log_analytics.name
# }

# output "log_analytics_workspace_id" {
#   description = "Workspace ID (GUID) del Log Analytics"
#   value       = module.log_analytics.workspace_id
# }

# output "log_analytics_primary_shared_key" {
#   description = "Primary Shared Key del Log Analytics"
#   value       = module.log_analytics.primary_shared_key
#   sensitive   = true
# }


# # ============================================
# # AZURE FUNCTIONS (WINDOWS) OUTPUTS
# # ============================================

# output "function_app_windows_ids" {
#   description = "IDs de las Azure Functions Windows"
#   value       = length(var.functions_windows) > 0 ? module.functions_windows.function_app_ids : {}
# }

# output "function_app_windows_names" {
#   description = "Nombres de las Azure Functions Windows"
#   value       = length(var.functions_windows) > 0 ? module.functions_windows.function_app_names : []
# }

# output "function_app_windows_hostnames" {
#   description = "Hostnames de las Azure Functions Windows"
#   value       = length(var.functions_windows) > 0 ? module.functions_windows.function_app_default_hostnames : {}
# }

# output "function_app_windows_identities" {
#   description = "Identities de las Azure Functions Windows"
#   value       = length(var.functions_windows) > 0 ? module.functions_windows.function_app_identities : {}
# }

# output "function_app_windows_storage_accounts" {
#   description = "Storage Accounts de las Azure Functions Windows"
#   value       = length(var.functions_windows) > 0 ? module.functions_windows.storage_account_names : []
# }

# output "function_app_windows_app_insights" {
#   description = "Application Insights de las Azure Functions Windows"
#   value       = length(var.functions_windows) > 0 ? module.functions_windows.application_insights_ids : {}
# }









# ### nuevos




# # ============================================
# # Functions Linux - DISPATCHER
# # ============================================

# output "functions_linux" {
#   description = "Información de Functions Linux (Dispatcher)"
#   value = length(var.functions_linux) > 0 ? {
#     function_apps    = module.functions_linux[0].function_apps
#     storage_accounts = module.functions_linux[0].storage_accounts
#   } : null
# }

# # ============================================
# # Functions Windows
# # ============================================

# output "functions_windows" {
#   description = "Información de Functions Windows"
#   value = length(var.functions_windows) > 0 ? {
#     function_apps    = module.functions_windows[0].function_apps
#     storage_accounts = module.functions_windows[0].storage_accounts
#     service_plans    = module.functions_windows[0].service_plans
#   } : null
# }


# # ============================================
# # Service Bus
# # ============================================

# output "service_bus" {
#   description = "Información del Service Bus"
#   value = {
#     namespace_id   = module.service_bus.namespace_id
#     namespace_name = module.service_bus.namespace_name
#     queues         = module.service_bus.queues
#     topics         = module.service_bus.topics
#     subscriptions  = module.service_bus.subscriptions
#   }
# }


# # ============================================
# # Storage Accounts
# # ============================================

# output "storage_accounts" {
#   description = "Información de los Storage Accounts independientes creados"
#   value = length(var.storage_accounts) > 0 ? {
#     accounts        = module.storage_accounts[0].storage_accounts
#     static_websites = module.storage_accounts[0].static_websites
#     containers      = module.storage_accounts[0].containers
#   } : null
#   sensitive = true
# }


# # ============================================
# # Cosmos DB
# # ============================================
# output "cosmos_db" {
#   description = "Información de Cosmos DB"
#   value = var.cosmos_db.create ? {
#     account_id    = module.cosmos_db[0].account_id
#     account_name  = module.cosmos_db[0].account_name
#     endpoint      = module.cosmos_db[0].endpoint
#     database_name = module.cosmos_db[0].database_name
#     containers    = module.cosmos_db[0].containers

#     # Network Info
#     public_access_enabled = module.cosmos_db[0].public_network_access_enabled
#     private_endpoint_id   = module.cosmos_db[0].private_endpoint_id
#     private_endpoint_ip   = module.cosmos_db[0].private_endpoint_ip
#   } : null
#   sensitive = true
# }



# output "key_vault" {
#   description = "Información del Key Vault"
#   value = var.key_vault.create ? {
#     id              = module.key_vault[0].id
#     name            = module.key_vault[0].name
#     vault_uri       = module.key_vault[0].vault_uri
#     tenant_id       = module.key_vault[0].tenant_id
#     secrets_created = module.key_vault[0].secrets_created
#   } : null
# }


# output "api_management" {
#   description = "Información de API Management"
#   value = var.api_management.create ? {
#     id                   = module.api_management[0].id
#     name                 = module.api_management[0].name
#     gateway_url          = module.api_management[0].gateway_url
#     gateway_regional_url = module.api_management[0].gateway_regional_url
#     management_api_url   = module.api_management[0].management_api_url
#     portal_url           = module.api_management[0].portal_url
#     developer_portal_url = module.api_management[0].developer_portal_url
#     public_ip_addresses  = module.api_management[0].public_ip_addresses
#     private_ip_addresses = module.api_management[0].private_ip_addresses
#   } : null
# }


# output "signalr" {
#   description = "Información de SignalR Service"
#   value = var.signalr.create ? {
#     id          = module.signalr[0].id
#     name        = module.signalr[0].name
#     hostname    = module.signalr[0].hostname
#     public_port = module.signalr[0].public_port
#     server_port = module.signalr[0].server_port
#   } : null
#   sensitive = true
# }



# # ============================================
# # VNet Outputs
# # ============================================

# output "vnet_id" {
#   description = "ID de la Virtual Network"
#   value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.vnet_id : null
# }

# output "vnet_name" {
#   description = "Nombre de la Virtual Network"
#   value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.vnet_name : null
# }

# output "vnet_address_space" {
#   description = "Espacio de direcciones de la VNet"
#   value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.vnet_address_space : null
# }

# output "subnet_ids" {
#   description = "IDs de las subnets"
#   value       = module.vnet.subnet_ids
# }

# output "subnet_names" {
#   description = "Nombres de las subnets"
#   value       = module.vnet.subnet_names
# }

# output "network_configuration" {
#   description = "Configuración completa de la red"
#   value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.network_configuration : null
# }



# # ============================================
# # FRONT DOOR OUTPUTS
# # ============================================

# output "front_door_profile_id" {
#   description = "ID del Front Door Profile"
#   value       = module.front_door.profile_id
# }

# output "front_door_profile_name" {
#   description = "Nombre del Front Door Profile"
#   value       = module.front_door.profile_name
# }

# output "front_door_endpoint_hostnames" {
#   description = "Hostnames de los endpoints de Front Door"
#   value       = module.front_door.endpoint_host_names
# }

# output "front_door_configuration" {
#   description = "Configuración completa del Front Door"
#   value       = module.front_door.front_door_configuration
# }



# ============================================
# ROOT - Outputs
# ============================================

# ============================================
# Resource Group
# ============================================

output "resource_group" {
  description = "Información del Resource Group"
  value = var.resource_group.create ? {
    id       = module.resource_group[0].resource_group_id
    name     = module.resource_group[0].resource_group_name
    location = module.resource_group[0].location
  } : null
}

# ============================================
# Application Insights & Log Analytics
# ============================================

output "application_insights_workspace" {
  description = "Workspace de Application Insights"
  value = var.application_insights.create_workspace ? {
    id                   = azurerm_log_analytics_workspace.shared[0].id
    workspace_id         = azurerm_log_analytics_workspace.shared[0].workspace_id
    primary_shared_key   = azurerm_log_analytics_workspace.shared[0].primary_shared_key
    secondary_shared_key = azurerm_log_analytics_workspace.shared[0].secondary_shared_key
  } : null
  sensitive = true
}

output "log_analytics" {
  description = "Log Analytics Workspace"
  value = var.log_analytics.create ? {
    id           = module.log_analytics[0].id
    workspace_id = module.log_analytics[0].workspace_id
    name         = module.log_analytics[0].name
  } : null
  sensitive = true
}

# ============================================
# Storage Accounts
# ============================================

output "storage_accounts" {
  description = "Información de los Storage Accounts"
  value = length(var.storage_accounts) > 0 ? {
    accounts        = module.storage_accounts[0].storage_accounts
    static_websites = module.storage_accounts[0].static_websites
    containers      = module.storage_accounts[0].containers
  } : null
  sensitive = true
}

# ============================================
# Service Bus
# ============================================

output "service_bus" {
  description = "Información del Service Bus"
  value = var.service_bus.create ? {
    namespace_id   = module.service_bus[0].namespace_id
    namespace_name = module.service_bus[0].namespace_name
    queues         = module.service_bus[0].queues
    topics         = module.service_bus[0].topics
    subscriptions  = module.service_bus[0].subscriptions
  } : null
}

# ============================================
# Cosmos DB
# ============================================

output "cosmos_db" {
  description = "Información de Cosmos DB"
  value = var.cosmos_db.create ? {
    account_id    = module.cosmos_db[0].account_id
    account_name  = module.cosmos_db[0].account_name
    endpoint      = module.cosmos_db[0].endpoint
    database_name = module.cosmos_db[0].database_name
    containers    = module.cosmos_db[0].containers

    public_access_enabled = module.cosmos_db[0].public_network_access_enabled
    private_endpoint_id   = module.cosmos_db[0].private_endpoint_id
    private_endpoint_ip   = module.cosmos_db[0].private_endpoint_ip
  } : null
  sensitive = true
}

# ============================================
# Key Vault
# ============================================

output "key_vault" {
  description = "Información del Key Vault"
  value = var.key_vault.create ? {
    id              = module.key_vault[0].id
    name            = module.key_vault[0].name
    vault_uri       = module.key_vault[0].vault_uri
    tenant_id       = module.key_vault[0].tenant_id
    secrets_created = module.key_vault[0].secrets_created
  } : null
}

# ============================================
# API Management
# ============================================

output "api_management" {
  description = "Información de API Management"
  value = var.api_management.create ? {
    id                   = module.api_management[0].id
    name                 = module.api_management[0].name
    gateway_url          = module.api_management[0].gateway_url
    gateway_regional_url = module.api_management[0].gateway_regional_url
    management_api_url   = module.api_management[0].management_api_url
    portal_url           = module.api_management[0].portal_url
    developer_portal_url = module.api_management[0].developer_portal_url
    public_ip_addresses  = module.api_management[0].public_ip_addresses
    private_ip_addresses = module.api_management[0].private_ip_addresses
  } : null
}

# ============================================
# SignalR
# ============================================

output "signalr" {
  description = "Información de SignalR Service"
  value = var.signalr.create ? {
    id          = module.signalr[0].id
    name        = module.signalr[0].name
    hostname    = module.signalr[0].hostname
    public_port = module.signalr[0].public_port
    server_port = module.signalr[0].server_port
  } : null
  sensitive = true
}

# ============================================
# VNet
# ============================================

output "vnet_id" {
  description = "ID de la Virtual Network"
  value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.vnet_id : null
}

output "vnet_name" {
  description = "Nombre de la Virtual Network"
  value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.vnet_name : null
}

output "vnet_address_space" {
  description = "Espacio de direcciones de la VNet"
  value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.vnet_address_space : null
}

output "subnet_ids" {
  description = "IDs de las subnets"
  value       = module.vnet.subnet_ids
}

output "subnet_names" {
  description = "Nombres de las subnets"
  value       = module.vnet.subnet_names
}

output "network_configuration" {
  description = "Configuración completa de la red"
  value       = var.vnet.create_vnet || length(var.vnet.subnets) > 0 ? module.vnet.network_configuration : null
}

# ============================================
# Functions Linux
# ============================================

output "functions_linux" {
  description = "Información de Functions Linux"
  value = length(var.functions_linux) > 0 ? {
    function_apps    = module.functions_linux[0].function_apps
    storage_accounts = module.functions_linux[0].storage_accounts
  } : null
}

# ============================================
# Functions Windows
# ============================================

output "functions_windows" {
  description = "Información de Functions Windows"
  value = length(var.functions_windows) > 0 ? {
    function_apps    = module.functions_windows[0].function_apps
    storage_accounts = module.functions_windows[0].storage_accounts
    service_plans    = module.functions_windows[0].service_plans
  } : null
}

# ============================================
# Front Door
# ============================================

output "front_door_profile_id" {
  description = "ID del Front Door Profile"
  value       = var.front_door.create ? module.front_door[0].profile_id : null
}

output "front_door_profile_name" {
  description = "Nombre del Front Door Profile"
  value       = var.front_door.create ? module.front_door[0].profile_name : null
}

output "front_door_endpoint_hostnames" {
  description = "Hostnames de los endpoints de Front Door"
  value       = var.front_door.create ? module.front_door[0].endpoint_host_names : null
}

output "front_door_configuration" {
  description = "Configuración completa del Front Door"
  value       = var.front_door.create ? module.front_door[0].front_door_configuration : null
}
