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
# Storage Accounts (INDEPENDIENTES)
# ============================================
# Solo para:
# 1. Static Website (Front Door)
# 2. StorageV2 general (blobs, tables)
# 
# Los Storage de Functions se crean DENTRO del módulo de Functions
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


