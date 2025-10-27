# ============================================
# Azure Function Windows Module - Main
# DISPATCHER
# ============================================

# Random strings para nombres únicos
resource "random_string" "storage_suffix" {
  for_each = { for f in var.functions : f.name => f }
  length   = 8
  special  = false
  upper    = false
}

resource "random_string" "plan_suffix" {
  for_each = { for f in var.functions : f.name => f if f.plan_type != null }
  length   = 4
  special  = false
  upper    = false
}

# Storage Accounts para Functions (solo si no se provee uno existente)
resource "azurerm_storage_account" "function" {
  for_each = {
    for f in var.functions : f.name => f
    if f.storage_account_name == null
  }

  name                     = lower(replace(substr("${each.value.name}${random_string.storage_suffix[each.key].result}", 0, 24), "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = var.tags
}

# App Service Plans - Basic (B1)
resource "azurerm_service_plan" "basic" {
  for_each = {
    for f in var.functions : f.name => f
    if f.plan_type == "basic"
  }

  name = coalesce(
    each.value.plan_name,
    "asp-${substr(each.value.name, 0, 40)}-${random_string.plan_suffix[each.key].result}"
  )
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "B1"

  tags = var.tags
}

# App Service Plans - Consumption (Y1)
resource "azurerm_service_plan" "consumption" {
  for_each = {
    for f in var.functions : f.name => f
    if f.plan_type == "consumption"
  }

  name = coalesce(
    each.value.plan_name,
    "asp-${substr(each.value.name, 0, 40)}-${random_string.plan_suffix[each.key].result}"
  )
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "Y1"

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "function" {
  for_each = {
    for f in var.functions : f.name => f
    if f.application_insights_enabled
  }

  name                = "${each.value.name}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.workspace_id

  tags = var.tags
}

# Windows Function Apps
resource "azurerm_windows_function_app" "function" {
  for_each = { for f in var.functions : f.name => f }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  enabled             = each.value.enabled # ← Control de estado

  service_plan_id = each.value.plan_type == "basic" ? (
    azurerm_service_plan.basic[each.key].id
    ) : (
    azurerm_service_plan.consumption[each.key].id
  )

  # Storage Account (existente o creado)
  storage_account_name = each.value.storage_account_name != null ? (
    each.value.storage_account_name
    ) : (
    azurerm_storage_account.function[each.key].name
  )

  storage_account_access_key = each.value.storage_account_name != null ? null : (
    azurerm_storage_account.function[each.key].primary_access_key
  )

  storage_uses_managed_identity = each.value.storage_uses_managed_identity

  site_config {
    always_on = each.value.always_on

    application_stack {
      dotnet_version              = each.value.dotnet_version
      use_dotnet_isolated_runtime = each.value.use_dotnet_isolated_runtime
    }

    # VNet Integration (IP Restrictions)
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
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.function[each.key].instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.function[each.key].connection_string
    } : {},
    {
      for setting in each.value.app_settings : setting.name => setting.value
    }
  )

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_ENABLE_SYNC_UPDATE_SITE"],
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}

# VNet Integration (Swift Connection)
resource "azurerm_app_service_virtual_network_swift_connection" "function" {
  for_each = {
    for f in var.functions : f.name => f
    if f.vnet_integration != null
  }

  app_service_id = azurerm_windows_function_app.function[each.key].id
  subnet_id      = each.value.vnet_integration.subnet_id
}

# Failure Anomalies Alert Rules
resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  for_each = {
    for f in var.functions : f.name => f
    if f.application_insights_enabled
  }

  name                = "Failure Anomalies - ${each.value.name}"
  resource_group_name = var.resource_group_name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.function[each.key].id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"

  description = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."

  action_group {
    ids = []
  }

  tags = var.tags
}