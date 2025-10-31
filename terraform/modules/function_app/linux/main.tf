# ============================================
# Azure Function Linux Module - Main
# Flex Consumption Plan - DISPATCHER
# ============================================

# Storage Account para cada Function
resource "azurerm_storage_account" "function" {
  for_each = { for f in var.functions : f.name => f }

  name                     = lower(replace(substr("${each.value.name}sa", 0, 24), "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  tags = var.tags
}

# Application Insights para cada Function
resource "azurerm_application_insights" "function" {
  for_each = { for f in var.functions : f.name => f }

  name                = "${each.value.name}-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = var.workspace_id

  tags = var.tags
}

# Flex Consumption Plan
resource "azapi_resource" "function_plan" {
  for_each = { for f in var.functions : f.name => f }

  type      = "Microsoft.Web/serverfarms@2023-12-01"
  name      = "${each.value.name}-plan"
  location  = var.location
  parent_id = var.resource_group_id

  body = {
    sku = {
      tier = "FlexConsumption"
      name = "FC1"
    }
    properties = {
      reserved = true
    }
  }

  schema_validation_enabled = false
  tags                      = var.tags
}

# Function App
# resource "azapi_resource" "function_app" {
#   for_each = { for f in var.functions : f.name => f }

#   type      = "Microsoft.Web/sites@2023-12-01"
#   name      = each.value.name
#   location  = var.location
#   parent_id = var.resource_group_id

#   identity {
#     type = "SystemAssigned"
#   }

#   body = {
#     kind = "functionapp,linux"
#     properties = {
#       serverFarmId = azapi_resource.function_plan[each.key].id
#       enabled      = each.value.enabled # ← Control de estado

#       siteConfig = {
#         appSettings = concat(
#           [
#             {
#               name  = "AzureWebJobsStorage__accountName"
#               value = azurerm_storage_account.function[each.key].name
#             },
#             {
#               name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
#               value = azurerm_application_insights.function[each.key].connection_string
#             },
#             {
#               name  = "FUNCTIONS_EXTENSION_VERSION"
#               value = "~4"
#             }
#           ],
#           [
#             for setting in each.value.app_settings : {
#               name  = setting.name
#               value = setting.value
#             }
#           ]
#         )
#       }
#       functionAppConfig = {
#         deployment = {
#           storage = {
#             type  = "blobContainer"
#             value = "${azurerm_storage_account.function[each.key].primary_blob_endpoint}deploymentpackage"
#             authentication = {
#               type = "SystemAssignedIdentity"
#             }
#           }
#         }
#         scaleAndConcurrency = {
#           maximumInstanceCount = each.value.maximum_instance_count
#           instanceMemoryMB     = each.value.instance_memory_mb
#         }
#         runtime = {
#           name    = each.value.runtime
#           version = each.value.version
#         }
#       }
#     }
#   }

#   schema_validation_enabled = false
#   tags                      = var.tags

#   depends_on = [
#     azapi_resource.function_plan,
#     azurerm_application_insights.function,
#     azurerm_storage_account.function
#   ]
# }

# Role Assignment
# resource "azurerm_role_assignment" "function_storage" {
#   for_each = { for f in var.functions : f.name => f }

#   scope                = azurerm_storage_account.function[each.key].id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = azapi_resource.function_app[each.key].output.identity.principalId  # ✅ Sin jsondecode
  
#   depends_on = [azapi_resource.function_app]
# }


# Function App
resource "azapi_resource" "function_app" {
  for_each = { for f in var.functions : f.name => f }

  type      = "Microsoft.Web/sites@2023-12-01"
  name      = each.value.name
  location  = var.location
  parent_id = var.resource_group_id

  identity {
    type = "SystemAssigned"  # ✅ Mantener (útil para otros servicios como Key Vault, Cosmos, etc.)
  }

  body = {
    kind = "functionapp,linux"
    properties = {
      serverFarmId = azapi_resource.function_plan[each.key].id
      enabled      = each.value.enabled

      siteConfig = {
        appSettings = concat(
          [
            {
              name  = "AzureWebJobsStorage"
              value = azurerm_storage_account.function[each.key].primary_connection_string
            },
            {
              name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
              value = azurerm_application_insights.function[each.key].connection_string
            },
            {
              name  = "FUNCTIONS_EXTENSION_VERSION"
              value = "~4"
            }
          ],
          [
            for setting in each.value.app_settings : {
              name  = setting.name
              value = setting.value
            }
          ]
        )
      }
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobContainer"
            value = "${azurerm_storage_account.function[each.key].primary_blob_endpoint}deploymentpackage"
            authentication = {
              type                               = "StorageAccountConnectionString"  # ✅ CAMBIAR esto
              storageAccountConnectionStringName = "AzureWebJobsStorage"              # ✅ AGREGAR esto
            }
          }
        }
        scaleAndConcurrency = {
          maximumInstanceCount = each.value.maximum_instance_count
          instanceMemoryMB     = each.value.instance_memory_mb
        }
        runtime = {
          name    = each.value.runtime
          version = each.value.version
        }
      }
    }
  }

  schema_validation_enabled = false
  tags                      = var.tags

  depends_on = [
    azapi_resource.function_plan,
    azurerm_application_insights.function,
    azurerm_storage_account.function
  ]
}

# (necesario para que la Function suba su código)
# resource "azurerm_role_assignment" "function_storage" {
#   for_each = { for f in var.functions : f.name => f }

#   scope                = azurerm_storage_account.function[each.key].id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = azapi_resource.function_app[each.key].output.identity.principalId

#   depends_on = [azapi_resource.function_app]
# }