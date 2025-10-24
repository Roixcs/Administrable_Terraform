# ============================================
# Azure Function Windows Module - Outputs
# DISPATCHER
# ============================================

output "function_apps" {
  description = "Información de las Function Apps creadas"
  value = {
    for name, func in azurerm_windows_function_app.function : name => {
      id               = func.id
      name             = func.name
      enabled          = func.enabled
      default_hostname = func.default_hostname
      principal_id     = try(func.identity[0].principal_id, null)
      kind             = func.kind
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

output "service_plans" {
  description = "App Service Plans creados"
  value = {
    basic = {
      for name, plan in azurerm_service_plan.basic : name => {
        id   = plan.id
        name = plan.name
      }
    }
    consumption = {
      for name, plan in azurerm_service_plan.consumption : name => {
        id   = plan.id
        name = plan.name
      }
    }
  }
}