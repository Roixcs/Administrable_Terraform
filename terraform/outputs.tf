output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = var.resource_group.create ? module.resource_group[0].name : var.resource_group.name
}

output "resource_group_id" {
  description = "ID del Resource Group"
  value       = var.resource_group.create ? module.resource_group[0].id : null
}

output "resource_group_location" {
  description = "Location del Resource Group"
  value       = var.resource_group.create ? module.resource_group[0].location : var.location
}

output "storage_accounts" {
  description = "Información de los Storage Accounts independientes creados"
  value = length(var.storage_accounts) > 0 ? {
    for key, sa in module.storage_account : key => {
      id                    = sa.id
      name                  = sa.name
      type                  = var.storage_accounts[key].storage_type
      primary_blob_endpoint = sa.primary_blob_endpoint
      primary_web_endpoint  = sa.primary_web_endpoint
    }
  } : {}
}

output "service_bus" {
  description = "Información del Service Bus"
  value = var.service_bus.create ? {
    namespace_id   = module.service_bus[0].namespace_id
    namespace_name = module.service_bus[0].namespace_name
    queues         = module.service_bus[0].queues
    topics         = module.service_bus[0].topics
  } : null
}

output "functions_linux" {
  description = "Información de Azure Functions Linux"
  value = length(var.functions_linux) > 0 ? {
    function_apps         = module.function_linux[0].function_apps
    storage_accounts      = module.function_linux[0].storage_accounts
  } : null
}

output "workspace_id" {
  description = "ID del Log Analytics Workspace compartido"
  value       = var.application_insights.create_workspace ? azurerm_log_analytics_workspace.shared[0].id : null
}