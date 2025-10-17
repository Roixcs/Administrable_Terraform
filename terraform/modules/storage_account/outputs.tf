# ============================================
# Storage Account Module - Outputs
# ============================================

output "id" {
  description = "ID del Storage Account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Nombre del Storage Account"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Endpoint primario de Blob"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_web_endpoint" {
  description = "Endpoint primario de Static Website"
  value       = azurerm_storage_account.this.primary_web_endpoint
}

output "primary_access_key" {
  description = "Primary Access Key del Storage Account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary Connection String del Storage Account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}