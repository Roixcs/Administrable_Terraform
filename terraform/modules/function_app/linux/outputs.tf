# ============================================
# Azure Function Linux Module - Outputs
# DISPATCHER
# ============================================

output "function_apps" {
  description = "Información de las Function Apps creadas"
  value = {
    for name, func in azapi_resource.function_app : name => {
      id               = func.id
      name             = func.name
      # enabled y state pueden no existir o estar en otra ubicación
      # Mejor usar solo lo que sabemos que existe:
      location         = func.output.location
      kind             = try(func.output.kind, null)
      principal_id     = try(func.output.identity.principalId, null)
      # O simplemente devolver todo:
      # properties       = func.output
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
      id                  = ai.id
      name                = ai.name
      instrumentation_key = ai.instrumentation_key
      connection_string   = ai.connection_string
    }
  }
  sensitive = true
}