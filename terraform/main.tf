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

# ============================================
# VNET
# ============================================

module "vnet" {
  source              = "./modules/vnet"
  create_vnet         = var.vnet.create
  vnet_name           = var.vnet.name
  address_space       = var.vnet.address_space
  dns_servers         = var.vnet.dns_servers
  subnets             = var.vnet.subnets
  resource_group_name = local.rg_name
  location            = var.location
  tags                = local.common_tags
  
  depends_on = [module.resource_group]
}


# ============================================
# LOG ANALYTICS WORKSPACE MODULE
# ============================================

module "log_analytics" {
  source                             = "./modules/log_analytics_workspace"
  create_log_analytics               = var.log_analytics.create
  name                               = var.log_analytics.name
  resource_group_name                = local.rg_name
  location                           = var.location
  sku                                = var.log_analytics.sku
  retention_in_days                  = var.log_analytics.retention_in_days
  daily_quota_gb                     = var.log_analytics.daily_quota_gb
  internet_ingestion_enabled         = var.log_analytics.internet_ingestion_enabled
  internet_query_enabled             = var.log_analytics.internet_query_enabled
  reservation_capacity_in_gb_per_day = var.log_analytics.reservation_capacity_in_gb_per_day
  tags                               = local.common_tags
  
  depends_on = [module.resource_group]
}


# ============================================
# FRONT DOOR MODULE
# ============================================

module "front_door" {
  source                   = "./modules/front_door"
  create_front_door        = var.front_door.create
  name                     = var.front_door.name
  resource_group_name      = local.rg_name
  sku_name                 = var.front_door.sku_name
  response_timeout_seconds = var.front_door.response_timeout_seconds
  endpoints                = var.front_door.endpoints
  origin_groups            = var.front_door.origin_groups
  origins                  = var.front_door.origins
  routes                   = var.front_door.routes
  custom_domains           = var.front_door.custom_domains
  tags                     = local.common_tags
  
  depends_on = [module.resource_group]
}

# ============================================
# AZURE FUNCTIONS (WINDOWS) MODULE
# ============================================

module "azure_functions_windows" {
  source                      = "./modules/function_app/windows"
  functions                   = var.functions_windows
  location                    = var.location
  resource_group_name         = local.rg_name
  log_analytics_workspace_id  = module.log_analytics.id
  tags                        = local.common_tags
  
  depends_on = [
    module.resource_group,
    module.log_analytics
  ]
}