# ============================================
# Azure Function Linux Module - Outputs
# ============================================

output "function_apps" {
  description = "Información de las Function Apps creadas"
  value = {
    for name, func in azapi_resource.function_app : name => {
      id                = func.id
      name              = func.name
      default_hostname  = jsondecode(func.output).properties.defaultHostName
      principal_id      = jsondecode(func.output).identity.principalId
    }
  }
}

output "storage_accounts" {
  description = "Storage Accounts creados para las Functions"
  value = {
    for name, sa in azurerm_storage_account.function : name => {
      id   = sa.id
      name = sa.name
    }
  }
}

output "application_insights" {
  description = "Application Insights creados para las Functions"
  value = {
    for name, ai in azurerm_application_insights.function : name => {
      id                 = ai.id
      name               = ai.name
      instrumentation_key = ai.instrumentation_key
      connection_string  = ai.connection_string
    }
  }
  sensitive = true
}