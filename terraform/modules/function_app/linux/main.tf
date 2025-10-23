###############################################################################
#  Azure Functions Linux (Flex Consumption) - Terraform Module
#  Version: 2.0 - Hybrid (Best of Both Worlds)
#  Compatible with azurerm >= 4.0 and azapi >= 1.15
###############################################################################

#########################
# Local Variables
#########################

locals {
  # Normaliza región (eastus → EUS, eastus2 → EUS2)
  region_alias = lower(var.location) == "eastus2" ? "EUS2" : lower(var.location) == "eastus" ? "EUS" : upper(replace(var.location, "-", ""))

  # Nombre canónico del workspace default de Azure
  default_workspace_name = "DefaultWorkspace-${var.subscription_id}-${local.region_alias}"
  default_rg_name        = "DefaultResourceGroup-${local.region_alias}"
}

#########################
# Log Analytics Workspace (Reutilizar o Crear)
#########################

# Buscar workspace existente
data "azurerm_log_analytics_workspace" "existing" {
  count               = var.reuse_existing_workspace ? 1 : 0
  name                = local.default_workspace_name
  resource_group_name = local.default_rg_name
}

# Crear solo si no existe y no se reutiliza
resource "azurerm_log_analytics_workspace" "workspace" {
  count = !var.reuse_existing_workspace && var.log_analytics_workspace_id == null ? 1 : 0

  name                = local.default_workspace_name
  location            = var.location
  resource_group_name = local.default_rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = var.tags
}

# Determinar qué workspace usar
locals {
  workspace_id = coalesce(
    var.log_analytics_workspace_id,                                 # 1. Si se pasa explícitamente
    try(data.azurerm_log_analytics_workspace.existing[0].id, null), # 2. Si existe el default
    try(azurerm_log_analytics_workspace.workspace[0].id, null)      # 3. Si se creó nuevo
  )
}

#########################
# Random Suffixes
#########################

resource "random_string" "storage_account_suffix" {
  for_each = { for func in var.functions : func.name => func if func.create }
  length   = 6
  special  = false
  upper    = false
}

#########################
# Storage Account
#########################

resource "azurerm_storage_account" "storage_account" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                     = lower(replace("st${substr(each.value.name, 0, 18)}${random_string.storage_account_suffix[each.key].result}", "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  tags = var.tags
}

#########################
# Deployment Container (Específico por Function)
#########################

resource "azurerm_storage_container" "function_deploy" {
  for_each              = { for func in var.functions : func.name => func if func.create }
  name                  = "app-package-${lower(each.value.name)}"
  storage_account_id    = azurerm_storage_account.storage_account[each.key].id  # ✅ CORREGIDO: Usar ID en lugar de name
  container_access_type = "private"
}

#########################
# Application Insights
#########################

resource "azurerm_application_insights" "app_insights" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                = "ai-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = local.workspace_id
  
  tags = var.tags
}

#########################
# Failure Anomalies Alert
#########################

resource "azurerm_monitor_smart_detector_alert_rule" "failure_anomalies" {
  for_each = { for func in var.functions : func.name => func if func.create }

  name                = "Failure Anomalies - ${each.value.name}"
  resource_group_name = var.resource_group_name
  detector_type       = "FailureAnomaliesDetector"
  scope_resource_ids  = [azurerm_application_insights.app_insights[each.key].id]
  severity            = "Sev3"
  frequency           = "PT1M"
  description         = "Alerts when failure rates increase abnormally."
  
  action_group {
    ids = []
  }
  
  tags = var.tags
}

#########################
# App Service Plan (Flex Consumption)
#########################

resource "azapi_resource" "serverFarm" {
  for_each = { for func in var.functions : func.name => func if func.create }

  type                      = "Microsoft.Web/serverfarms@2023-12-01"
  schema_validation_enabled = false
  name                      = "asp-${each.value.name}"
  location                  = var.location
  parent_id                 = var.resource_group_id

  body = {
    kind = "functionapp"
    sku = {
      name = "FC1"
      tier = "FlexConsumption"
    }
    properties = {
      reserved = true
    }
  }
  
  tags = var.tags
}

#########################
# Function App (Linux Flex)
#########################

resource "azapi_resource" "functionApps" {
  for_each = { for func in var.functions : func.name => func if func.create }

  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = var.location
  name                      = each.value.name
  parent_id                 = var.resource_group_id

  body = {
    kind = "functionapp,linux"
    
    # Identity SIEMPRE activa
    identity = {
      type = "SystemAssigned"
    }
    
    properties = {
      serverFarmId = azapi_resource.serverFarm[each.key].id
      
      # Deployment Settings
      functionAppConfig = {
        deployment = {
          storage = {
            type = "blobContainer"
            
            # URL completa del contenedor
            value = "https://${azurerm_storage_account.storage_account[each.key].name}.blob.core.windows.net/${azurerm_storage_container.function_deploy[each.key].name}"
            
            # Metadata adicional
            storageAccountResourceId = azurerm_storage_account.storage_account[each.key].id
            containerName            = azurerm_storage_container.function_deploy[each.key].name
            
            # Autenticación (Connection String)
            authentication = {
              type                              = "StorageAccountConnectionString"
              storageAccountConnectionStringName = "DEPLOYMENT_STORAGE_CONNECTION_STRING"
            }
          }
        }
        
        runtime = {
          name    = "dotnet-isolated"
          version = "8.0"
        }
        
        scaleAndConcurrency = {
          maximumInstanceCount = 40
          instanceMemoryMB     = 2048
        }
      }
      
      # App Settings COMPLETOS
      siteConfig = {
        appSettings = concat(
          [
            # Application Insights
            {
              name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
              value = azurerm_application_insights.app_insights[each.key].connection_string
            },
            {
              name  = "APPINSIGHTS_INSTRUMENTATIONKEY"
              value = azurerm_application_insights.app_insights[each.key].instrumentation_key
            },
            
            # Storage - AzureWebJobsStorage
            {
              name  = "AzureWebJobsStorage"
              value = azurerm_storage_account.storage_account[each.key].primary_connection_string
            },
            
            # Deployment Storage
            {
              name  = "DEPLOYMENT_STORAGE_CONNECTION_STRING"
              value = azurerm_storage_account.storage_account[each.key].primary_connection_string
            },
            {
              name  = "DEPLOYMENT_STORAGE_ACCOUNT_NAME"
              value = azurerm_storage_account.storage_account[each.key].name
            },
            {
              name  = "DEPLOYMENT_CONTAINER"
              value = azurerm_storage_container.function_deploy[each.key].name
            },
            
            # Website Content
            {
              name  = "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"
              value = azurerm_storage_account.storage_account[each.key].primary_connection_string
            },
            {
              name  = "WEBSITE_CONTENTSHARE"
              value = lower(each.value.name)
            },
            
            # Runtime Settings
            {
              name  = "FUNCTIONS_WORKER_RUNTIME"
              value = "dotnet-isolated"
            },
            {
              name  = "DOTNET_VERSION"
              value = "8.0"
            }
          ],
          
          # Settings personalizados del usuario
          [for setting in each.value.app_settings : {
            name  = setting.name
            value = setting.value
          }]
        )
      }
    }
  }
  
  tags = var.tags

  depends_on = [
    azapi_resource.serverFarm,
    azurerm_storage_account.storage_account,
    azurerm_storage_container.function_deploy,
    azurerm_application_insights.app_insights
  ]
}