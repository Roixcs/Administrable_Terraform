# ============================================
# Storage Account Module - Main
# ============================================
# Storage Accounts INDEPENDIENTES (no para Functions)
# Tipos soportados:
# 1. static_website - Para Front Door endpoints
# 2. general - StorageV2 para blobs, tables, queues
# ============================================

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"  # Siempre StorageV2
  
  # Seguridad
  https_traffic_only_enabled = var.enable_https_traffic_only
  min_tls_version            = var.min_tls_version
  
  tags = var.tags
  
  lifecycle {
    prevent_destroy = false  # Cambiar a true en producción
  }
}

# Static Website (recurso separado en azurerm 4.x)
resource "azurerm_storage_account_static_website" "this" {
  count = var.storage_type == "static_website" ? 1 : 0
  
  storage_account_id = azurerm_storage_account.this.id
  index_document     = var.index_document
  error_404_document = var.error_404_document
}