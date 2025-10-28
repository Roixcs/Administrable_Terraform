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


# # ============================================
# # Resource Group
# # ============================================

# module "resource_group" {
#   count  = var.resource_group.create ? 1 : 0
#   source = "./modules/resource_group"

#   name     = var.resource_group.name
#   location = var.location
#   tags     = local.common_tags
# }

# # ============================================
# # Application Insights Workspace
# # ============================================

# resource "azurerm_log_analytics_workspace" "shared" {
#   count               = var.application_insights.create_workspace ? 1 : 0
#   name                = coalesce(var.application_insights.workspace_name, "${local.name_prefix}-law")
#   location            = var.location
#   resource_group_name = local.rg_name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30

#   tags = local.common_tags

#   depends_on = [module.resource_group]
# }


# # ============================================
# # LOG ANALYTICS WORKSPACE MODULE
# # ============================================

# module "log_analytics" {
#   source                             = "./modules/log_analytics_workspace"
#   create_log_analytics               = var.log_analytics.create
#   name                               = var.log_analytics.name
#   resource_group_name                = local.rg_name
#   location                           = var.location
#   sku                                = var.log_analytics.sku
#   retention_in_days                  = var.log_analytics.retention_in_days
#   daily_quota_gb                     = var.log_analytics.daily_quota_gb
#   internet_ingestion_enabled         = var.log_analytics.internet_ingestion_enabled
#   internet_query_enabled             = var.log_analytics.internet_query_enabled
#   reservation_capacity_in_gb_per_day = var.log_analytics.reservation_capacity_in_gb_per_day
#   tags                               = local.common_tags

#   depends_on = [module.resource_group]
# }

# # ============================================
# # Azure Functions Linux
# # ============================================

# module "functions_linux" {
#   count  = length(var.functions_linux) > 0 ? 1 : 0
#   source = "./modules/function_app/linux"

#   functions           = var.functions_linux
#   resource_group_name = local.rg_name
#   resource_group_id   = local.rg_id
#   location            = var.location
#   workspace_id        = var.application_insights.create_workspace ? azurerm_log_analytics_workspace.shared[0].id : null
#   tags                = local.common_tags

#   depends_on = [
#     module.resource_group,
#     azurerm_log_analytics_workspace.shared
#   ]
# }


# # ============================================
# # Azure Functions Windows
# # ============================================

# module "functions_windows" {
#   count  = length(var.functions_windows) > 0 ? 1 : 0
#   source = "./modules/function_app/windows"

#   functions           = var.functions_windows
#   resource_group_name = local.rg_name
#   location            = var.location
#   workspace_id        = var.application_insights.create_workspace ? azurerm_log_analytics_workspace.shared[0].id : null
#   tags                = local.common_tags

#   depends_on = [
#     module.resource_group,
#     azurerm_log_analytics_workspace.shared
#   ]
# }



# # ============================================
# # Service Bus
# # ============================================

# module "service_bus" {
#   source = "./modules/service_bus"

#   namespace_name      = var.service_bus.namespace_name
#   resource_group_name = local.rg_name
#   location            = var.location
#   sku                 = var.service_bus.sku
#   queues              = var.service_bus.queues
#   topics              = var.service_bus.topics
#   tags                = local.common_tags

#   depends_on = [module.resource_group]
# }


# # ============================================
# # Storage Accounts (INDEPENDIENTES)
# # ============================================
# # Solo para:
# # 1. Static Website (Front Door/CDN)
# # 2. StorageV2 general (blobs, tables, queues)
# # 
# # Los Storage de Functions se crean DENTRO del módulo de Functions
# # ============================================

# module "storage_accounts" {
#   count  = length(var.storage_accounts) > 0 ? 1 : 0
#   source = "./modules/storage_account"

#   storage_accounts    = var.storage_accounts
#   resource_group_name = local.rg_name
#   location            = var.location
#   tags                = local.common_tags

#   depends_on = [module.resource_group]
# }


# # ============================================
# # Cosmos DB
# # ============================================

# module "cosmos_db" {
#   count  = var.cosmos_db.create ? 1 : 0
#   source = "./modules/cosmos_db"

#   account_name        = var.cosmos_db.account_name
#   resource_group_name = local.rg_name
#   location            = var.location
#   database_name       = var.cosmos_db.database_name
#   enable_serverless   = var.cosmos_db.enable_serverless
#   consistency_level   = var.cosmos_db.consistency_level
#   containers          = var.cosmos_db.containers

#   # Network Configuration
#   public_network_access_enabled = var.cosmos_db.public_network_access_enabled
#   ip_range_filter               = var.cosmos_db.ip_range_filter
#   virtual_network_rules         = var.cosmos_db.virtual_network_rules
#   enable_private_endpoint       = var.cosmos_db.enable_private_endpoint
#   private_endpoint_subnet_id    = var.cosmos_db.private_endpoint_subnet_id

#   tags = local.common_tags

#   depends_on = [module.resource_group]
# }

# # ============================================
# # Key Vault
# # ============================================
# module "key_vault" {
#   count  = var.key_vault.create ? 1 : 0
#   source = "./modules/key_vault"

#   name                       = var.key_vault.name
#   resource_group_name        = local.rg_name
#   location                   = var.location
#   tenant_id                  = var.tenant_id
#   sku_name                   = var.key_vault.sku_name
#   soft_delete_retention_days = var.key_vault.soft_delete_retention_days
#   purge_protection_enabled   = var.key_vault.purge_protection_enabled
#   enable_rbac_authorization  = var.key_vault.enable_rbac_authorization

#   # Permisos para servicios Azure
#   enabled_for_deployment          = var.key_vault.enabled_for_deployment
#   enabled_for_disk_encryption     = var.key_vault.enabled_for_disk_encryption
#   enabled_for_template_deployment = var.key_vault.enabled_for_template_deployment

#   # Network ACLs
#   network_acls = var.key_vault.network_acls

#   # Secretos (opcional)
#   secrets = var.key_vault.secrets

#   tags = local.common_tags

#   depends_on = [module.resource_group]
# }

# # ============================================
# # API Management
# # ============================================

# module "api_management" {
#   count  = var.api_management.create ? 1 : 0
#   source = "./modules/api_management"

#   name                = var.api_management.name
#   resource_group_name = local.rg_name
#   location            = var.location
#   publisher_name      = var.api_management.publisher_name
#   publisher_email     = var.api_management.publisher_email
#   sku_name            = var.api_management.sku_name

#   # VNet Configuration
#   virtual_network_type          = var.api_management.virtual_network_type
#   virtual_network_configuration = var.api_management.virtual_network_configuration
#   public_ip_address_id          = var.api_management.public_ip_address_id

#   tags = local.common_tags

#   depends_on = [module.resource_group]
# }

# # ============================================
# # SignalR Service
# # ============================================

# module "signalr" {
#   count  = var.signalr.create ? 1 : 0
#   source = "./modules/signalr"

#   name                          = var.signalr.name
#   resource_group_name           = local.rg_name
#   location                      = var.location
#   sku                           = var.signalr.sku
#   capacity                      = var.signalr.capacity
#   service_mode                  = var.signalr.service_mode
#   cors_allowed_origins          = var.signalr.cors_allowed_origins
#   public_network_access_enabled = var.signalr.public_network_access_enabled

#   tags = local.common_tags

#   depends_on = [module.resource_group]
# }


# # ============================================
# # Virtual Network
# # ============================================

# module "vnet" {
#   source = "./modules/vnet"

#   create_vnet         = var.vnet.create_vnet
#   vnet_name           = var.vnet.vnet_name
#   resource_group_name = coalesce(var.vnet.resource_group_name, local.rg_name)
#   location            = var.location
#   address_space       = var.vnet.address_space
#   dns_servers         = var.vnet.dns_servers
#   subnets             = var.vnet.subnets

#   tags = local.common_tags

#   depends_on = [module.resource_group]
# }

# # ============================================
# # FRONT DOOR MODULE
# # ============================================

# module "front_door" {
#   source                   = "./modules/front_door"
#   create_front_door        = var.front_door.create
#   name                     = var.front_door.name
#   resource_group_name      = local.rg_name
#   sku_name                 = var.front_door.sku_name
#   response_timeout_seconds = var.front_door.response_timeout_seconds
#   endpoints                = var.front_door.endpoints
#   origin_groups            = var.front_door.origin_groups
#   origins                  = var.front_door.origins
#   routes                   = var.front_door.routes
#   custom_domains           = var.front_door.custom_domains
#   rule_sets                = var.front_door.rule_sets
#   rules                    = var.front_door.rules
#   tags                     = local.common_tags

#   depends_on = [
#     module.resource_group,
#     module.storage_accounts
#   ]
# }



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
# LOG ANALYTICS WORKSPACE MODULE
# ============================================

module "log_analytics" {
  count  = var.log_analytics.create ? 1 : 0
  source = "./modules/log_analytics_workspace"

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
# Storage Accounts (INDEPENDIENTES)
# ============================================

module "storage_accounts" {
  count  = length(var.storage_accounts) > 0 ? 1 : 0
  source = "./modules/storage_account"

  storage_accounts    = var.storage_accounts
  resource_group_name = local.rg_name
  location            = var.location
  tags                = local.common_tags

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

  # Network Configuration
  public_network_access_enabled = var.cosmos_db.public_network_access_enabled
  ip_range_filter               = var.cosmos_db.ip_range_filter
  virtual_network_rules         = var.cosmos_db.virtual_network_rules
  enable_private_endpoint       = var.cosmos_db.enable_private_endpoint
  private_endpoint_subnet_id    = var.cosmos_db.private_endpoint_subnet_id

  tags = local.common_tags

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

  enabled_for_deployment          = var.key_vault.enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault.enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault.enabled_for_template_deployment

  network_acls = var.key_vault.network_acls
  secrets      = var.key_vault.secrets

  tags = local.common_tags

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

  virtual_network_type          = var.api_management.virtual_network_type
  virtual_network_configuration = var.api_management.virtual_network_configuration
  public_ip_address_id          = var.api_management.public_ip_address_id

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# ============================================
# SignalR Service
# ============================================

module "signalr" {
  count  = var.signalr.create ? 1 : 0
  source = "./modules/signalr"

  name                          = var.signalr.name
  resource_group_name           = local.rg_name
  location                      = var.location
  sku                           = var.signalr.sku
  capacity                      = var.signalr.capacity
  service_mode                  = var.signalr.service_mode
  cors_allowed_origins          = var.signalr.cors_allowed_origins
  public_network_access_enabled = var.signalr.public_network_access_enabled

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# ============================================
# Virtual Network
# ============================================

module "vnet" {
  source = "./modules/vnet"

  create_vnet         = var.vnet.create_vnet
  vnet_name           = var.vnet.vnet_name
  resource_group_name = coalesce(var.vnet.resource_group_name, local.rg_name)
  location            = var.location
  address_space       = var.vnet.address_space
  dns_servers         = var.vnet.dns_servers
  subnets             = var.vnet.subnets

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# ============================================
# Azure Functions Linux
# ============================================

module "functions_linux" {
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
# Azure Functions Windows
# ============================================

module "functions_windows" {
  count  = length(var.functions_windows) > 0 ? 1 : 0
  source = "./modules/function_app/windows"

  functions           = var.functions_windows
  resource_group_name = local.rg_name
  location            = var.location
  workspace_id        = var.application_insights.create_workspace ? azurerm_log_analytics_workspace.shared[0].id : null
  tags                = local.common_tags

  depends_on = [
    module.resource_group,
    azurerm_log_analytics_workspace.shared
  ]
}

# ============================================
# Front Door
# ============================================

module "front_door" {
  count  = var.front_door.create ? 1 : 0
  source = "./modules/front_door"

  name                     = var.front_door.name
  resource_group_name      = local.rg_name
  sku_name                 = var.front_door.sku_name
  response_timeout_seconds = var.front_door.response_timeout_seconds
  endpoints                = var.front_door.endpoints
  origin_groups            = var.front_door.origin_groups
  origins                  = var.front_door.origins
  routes                   = var.front_door.routes
  custom_domains           = var.front_door.custom_domains
  rule_sets                = var.front_door.rule_sets
  rules                    = var.front_door.rules
  tags                     = local.common_tags

  depends_on = [
    module.resource_group,
    module.storage_accounts
  ]
}
