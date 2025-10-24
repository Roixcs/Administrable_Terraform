# ============================================
# Storage Account Module - Main
# DISPATCHER - Múltiples Storage Accounts
# ============================================
# Tipos soportados:
# 1. static_website - Para Front Door/CDN
# 2. general - StorageV2 para blobs, tables, queues
# ============================================

resource "azurerm_storage_account" "this" {
  for_each = { for sa in var.storage_accounts : sa.name => sa }
  
  name                     = each.value.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind             = "StorageV2"
  
  # Seguridad
  https_traffic_only_enabled = each.value.enable_https_traffic_only
  min_tls_version            = each.value.min_tls_version
  
  # Access Tier (solo para StorageV2 y BlobStorage)
  access_tier = each.value.access_tier
  
  tags = var.tags
  
  lifecycle {
    prevent_destroy = false  # Cambiar a true en producción
  }
}

# Static Website (solo si storage_type = "static_website")
resource "azurerm_storage_account_static_website" "this" {
  for_each = { 
    for sa in var.storage_accounts : sa.name => sa 
    if sa.storage_type == "static_website" 
  }
  
  storage_account_id = azurerm_storage_account.this[each.key].id
  index_document     = each.value.index_document
  error_404_document = each.value.error_404_document
}

# Blob Containers (opcional)
resource "azurerm_storage_container" "this" {
  for_each = merge([
    for sa in var.storage_accounts : {
      for container in sa.containers :
      "${sa.name}/${container.name}" => {
        storage_account_name  = sa.name
        container_name        = container.name
        container_access_type = container.access_type
      }
    }
  ]...)
  
  name                  = each.value.container_name
  storage_account_name  = azurerm_storage_account.this[each.value.storage_account_name].name
  container_access_type = each.value.container_access_type
}

# Lifecycle Management Policy (opcional)
resource "azurerm_storage_management_policy" "this" {
  for_each = {
    for sa in var.storage_accounts : sa.name => sa
    if sa.lifecycle_rules != null && length(sa.lifecycle_rules) > 0
  }
  
  storage_account_id = azurerm_storage_account.this[each.key].id
  
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled
      
      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
      }
      
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days
        }
      }
    }
  }
}