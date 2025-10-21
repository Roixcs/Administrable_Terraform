# Function App Outputs
output "function_app_ids" {
  description = "Mapa de IDs de las Function Apps"
  value = {
    for key, func in azurerm_windows_function_app.function_app : key => func.id
  }
}

output "function_app_names" {
  description = "Lista de nombres de las Function Apps"
  value = [
    for func in azurerm_windows_function_app.function_app : func.name
  ]
}

output "function_app_default_hostnames" {
  description = "Mapa de default hostnames de las Function Apps"
  value = {
    for key, func in azurerm_windows_function_app.function_app : key => func.default_hostname
  }
}

output "function_app_identities" {
  description = "Mapa de identities de las Function Apps"
  value = {
    for key, func in azurerm_windows_function_app.function_app : key => {
      principal_id = try(func.identity[0].principal_id, null)
      tenant_id    = try(func.identity[0].tenant_id, null)
      type         = try(func.identity[0].type, null)
    }
  }
}

# Storage Account Outputs
output "storage_account_names" {
  description = "Lista de nombres de Storage Accounts"
  value = [
    for account in azurerm_storage_account.storage_account : account.name
  ]
}

output "storage_account_ids" {
  description = "Mapa de IDs de Storage Accounts"
  value = {
    for key, account in azurerm_storage_account.storage_account : key => account.id
  }
}

# Application Insights Outputs
output "application_insights_ids" {
  description = "Mapa de IDs de Application Insights"
  value = {
    for key, ai in azurerm_application_insights.app_insights : key => ai.id
  }
}

output "application_insights_instrumentation_keys" {
  description = "Mapa de instrumentation keys de Application Insights"
  value = {
    for key, ai in azurerm_application_insights.app_insights : key => ai.instrumentation_key
  }
  sensitive = true
}

output "application_insights_connection_strings" {
  description = "Mapa de connection strings de Application Insights"
  value = {
    for key, ai in azurerm_application_insights.app_insights : key => ai.connection_string
  }
  sensitive = true
}

# App Service Plans Outputs
output "basic_plan_ids" {
  description = "Mapa de IDs de los App Service Plans Basic"
  value = {
    for key, plan in azurerm_service_plan.basic_plan : key => plan.id
  }
}

output "consumption_plan_ids" {
  description = "Mapa de IDs de los App Service Plans Consumption"
  value = {
    for key, plan in azurerm_service_plan.consumption_plan : key => plan.id
  }
}