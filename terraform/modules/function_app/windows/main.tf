# Random strings para nombres únicos
resource "random_string" "storage_account_suffix" {
  for_each = { for func in var.functions : func.name => func if func.create }
  length   = 8
  special  = false
  upper    = false
}

resource "random_string" "plan_suffix_basic" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "basic" && func.create }
  length   = 4
  special  = false
  upper    = false
}

resource "random_string" "plan_suffix_consumption" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "consumption" && func.create }
  length   = 4
  special  = false
  upper    = false
}

# Storage Accounts para Functions
resource "azurerm_storage_account" "storage_account" {
  for_each = { for func in var.functions : func.name => func if func.create && func.storage_account_name == null }

  name                     = "${replace(replace(substr(each.value.name, 0, 20), "-", ""), "fn", "")}${random_string.storage_account_suffix[each.key].result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  tags = var.tags
}

# App Service Plans - Basic (B1)
resource "azurerm_service_plan" "basic_plan" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "basic" && func.create }

  name                = coalesce(
    each.value.plan_name, 
    "asp-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_basic[each.key].result}"
  )
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "B1"
  
  tags = var.tags
}

# App Service Plans - Consumption (Y1)
resource "azurerm_service_plan" "consumption_plan" {
  for_each = { for func in var.functions : func.name => func if func.plan_type == "consumption" && func.create }

  name                = "asp-${replace(substr(each.value.name, 0, 24), "-", "")}-${random_string.plan_suffix_consumption[each.key].result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "Y1"
  
  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  for_each = { for func in var.functions : func.name => func if func.create && func.application_insights_enabled }

  name                = "ai-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id
  
  tags = var.tags
}

# Failure Anomalies Alert Rules
resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  for_each = { for func in var.functions : func.name => func if func.create && func.application_insights_enabled }

  name                = "Failure Anomalies - ${each.value.name}"
  resource_group_name = var.resource_group_name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.app_insights[each.key].id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
  
  description = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."
  
  action_group {
    ids = []
  }
  
  tags = var.tags
}

# Windows Function Apps
resource "azurerm_windows_function_app" "function_app" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                       = each.value.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = each.value.plan_type == "basic" ? azurerm_service_plan.basic_plan[each.key].id : azurerm_service_plan.consumption_plan[each.key].id
  storage_account_name       = each.value.storage_account_name != null ? each.value.storage_account_name : azurerm_storage_account.storage_account[each.key].name
  storage_account_access_key = each.value.storage_account_name != null ? null : azurerm_storage_account.storage_account[each.key].primary_access_key
  storage_uses_managed_identity = each.value.storage_uses_managed_identity
  
  site_config {
    always_on = each.value.always_on
    
    application_stack {
      dotnet_version              = each.value.dotnet_version
      use_dotnet_isolated_runtime = each.value.use_dotnet_isolated_runtime
    }
    
    # VNet Integration
    dynamic "ip_restriction" {
      for_each = each.value.vnet_integration != null ? [1] : []
      content {
        virtual_network_subnet_id = each.value.vnet_integration.subnet_id
        action                    = "Allow"
        priority                  = 100
        name                      = "VNetIntegration"
      }
    }
  }
  
  # Identity
  dynamic "identity" {
    for_each = each.value.identity_type != null ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = each.value.identity_type == "UserAssigned" ? each.value.identity_ids : null
    }
  }
  
  # App Settings
  app_settings = merge(
    each.value.application_insights_enabled ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app_insights[each.key].instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights[each.key].connection_string
    } : {},
    {
      for setting in each.value.app_settings : setting.name => setting.value
    }
  )
  
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      tags,
      app_settings
    ]
  }
}

# VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  for_each = { for func in var.functions : func.name => func if func.create && func.vnet_integration != null }

  app_service_id = azurerm_windows_function_app.function_app[each.key].id
  subnet_id      = each.value.vnet_integration.subnet_id
}