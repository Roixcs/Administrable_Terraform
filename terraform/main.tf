# ============================================
# Main Terraform Configuration
# ============================================

# ============================================
# Locals
# ============================================

locals {
  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"

  # Resource Group name (creado o existente)
  rg_name = var.resource_group.create ? module.resource_group[0].name : var.resource_group.name
  rg_id   = var.resource_group.create ? module.resource_group[0].id : "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group.name}"
  
  
  # Tags comunes
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ============================================
# Storage Accounts (INDEPENDIENTES)
# ============================================
# Solo para:
# 1. Static Website (Front Door)
# 2. StorageV2 general (blobs, tables)
# 
# Los Storage de Functions se crean DENTRO del módulo de Functions
# ============================================
# ============================================
# Resource Group
# ============================================

module "resource_group" {
  count  = var.resource_group.create ? 1 : 0
  source = "./modules/resource_group"
  
  name     = var.resource_group.name
  location = var.location
  tags     = local.common_tags
}

# ============================================
# Application Insights Workspace
# ============================================

resource "azurerm_log_analytics_workspace" "shared" {
  count               = var.application_insights.create_workspace ? 1 : 0
  name                = coalesce(var.application_insights.workspace_name, "${local.name_prefix}-law")
  location            = var.location
  resource_group_name = local.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# Storage Accounts (INDEPENDIENTES)
# ============================================

module "storage_account" {
  for_each = var.storage_accounts
  source   = "./modules/storage_account"
  
  name                     = each.value.name
  storage_type             = each.value.storage_type
  resource_group_name      = local.rg_name
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  tags                     = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# Service Bus
# ============================================

module "service_bus" {
  count  = var.service_bus.create ? 1 : 0
  source = "./modules/service_bus"
  
  namespace_name      = var.service_bus.namespace_name
  resource_group_name = local.rg_name
  location            = var.location
  sku                 = var.service_bus.sku
  queues              = var.service_bus.queues
  topics              = var.service_bus.topics
  tags                = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# Azure Functions Linux
# ============================================

module "function_linux" {
  count  = length(var.functions_linux) > 0 ? 1 : 0
  source = "./modules/function_app/linux"
  
  functions           = var.functions_linux
  resource_group_name = local.rg_name
  resource_group_id   = local.rg_id
  location            = var.location
  workspace_id        = var.application_insights.create_workspace ? azurerm_log_analytics_workspace.shared[0].id : null
  tags                = local.common_tags
  
  depends_on = [
    module.resource_group,
    azurerm_log_analytics_workspace.shared
  ]
}

# ============================================
# Cosmos DB
# ============================================

module "cosmos_db" {
  count  = var.cosmos_db.create ? 1 : 0
  source = "./modules/cosmos_db"
  
  account_name        = var.cosmos_db.account_name
  resource_group_name = local.rg_name
  location            = var.location
  database_name       = var.cosmos_db.database_name
  enable_serverless   = var.cosmos_db.enable_serverless
  consistency_level   = var.cosmos_db.consistency_level
  containers          = var.cosmos_db.containers
  tags                = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# Key Vault
# ============================================

module "key_vault" {
  count  = var.key_vault.create ? 1 : 0
  source = "./modules/key_vault"
  
  name                       = var.key_vault.name
  resource_group_name        = local.rg_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = var.key_vault.sku_name
  soft_delete_retention_days = var.key_vault.soft_delete_retention_days
  purge_protection_enabled   = var.key_vault.purge_protection_enabled
  enable_rbac_authorization  = var.key_vault.enable_rbac_authorization
  tags                       = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# API Management
# ============================================

module "api_management" {
  count  = var.api_management.create ? 1 : 0
  source = "./modules/api_management"
  
  name                = var.api_management.name
  resource_group_name = local.rg_name
  location            = var.location
  publisher_name      = var.api_management.publisher_name
  publisher_email     = var.api_management.publisher_email
  sku_name            = var.api_management.sku_name
  tags                = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# SignalR Service
# ============================================

module "signalr" {
  count  = var.signalr.create ? 1 : 0
  source = "./modules/signalr"
  
  name                = var.signalr.name
  resource_group_name = local.rg_name
  location            = var.location
  sku                 = var.signalr.sku
  capacity            = var.signalr.capacity
  service_mode        = var.signalr.service_mode
  tags                = local.common_tags
  
  depends_on = [module.resource_group]
}