# Function App Outputs
output "function_app_ids" {
  description = "IDs de las Function Apps"
  value = {
    for key, func in azapi_resource.functionApps : key => func.id
  }
}

output "function_app_names" {
  description = "Nombres de las Function Apps"
  value = [
    for func in azapi_resource.functionApps : func.name
  ]
}

output "function_app_identities" {
  description = "System Assigned Identities"
  value = {
    for key, func in azapi_resource.functionApps : key => {
      principal_id = jsondecode(func.output).identity.principalId
      tenant_id    = jsondecode(func.output).identity.tenantId
    }
  }
}

# Storage Account Outputs
output "storage_account_names" {
  description = "Nombres de Storage Accounts"
  value = {
    for key, sa in azurerm_storage_account.storage_account : key => sa.name
  }
}

output "storage_account_ids" {
  description = "IDs de Storage Accounts"
  value = {
    for key, sa in azurerm_storage_account.storage_account : key => sa.id
  }
}

# Application Insights Outputs
output "application_insights_ids" {
  description = "IDs de Application Insights"
  value = {
    for key, ai in azurerm_application_insights.app_insights : key => ai.id
  }
}

output "application_insights_connection_strings" {
  description = "Connection Strings de Application Insights"
  value = {
    for key, ai in azurerm_application_insights.app_insights : key => ai.connection_string
  }
  sensitive = true
}

# Log Analytics Workspace Output
output "workspace_id" {
  description = "ID del Log Analytics Workspace usado"
  value       = local.workspace_id
}

# Server Farm (App Service Plan) Outputs
output "server_farm_ids" {
  description = "IDs de los App Service Plans (Flex Consumption)"
  value = {
    for key, plan in azapi_resource.serverFarm : key => plan.id
  }
}