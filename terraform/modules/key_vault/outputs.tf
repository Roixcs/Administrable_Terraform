# ============================================
# Key Vault Module - Outputs
# ============================================

output "id" {
  description = "ID del Key Vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Nombre del Key Vault"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "URI del Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "tenant_id" {
  description = "Tenant ID del Key Vault"
  value       = azurerm_key_vault.this.tenant_id
}

output "secrets_created" {
  description = "Lista de secretos creados"
  value       = [for s in azurerm_key_vault_secret.this : s.name]
}