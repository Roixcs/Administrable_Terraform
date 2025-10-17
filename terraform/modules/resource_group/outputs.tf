# ============================================
# Resource Group Module - Outputs
# ============================================

output "name" {
  description = "Nombre del Resource Group creado"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Location del Resource Group"
  value       = azurerm_resource_group.this.location
}

output "id" {
  description = "ID del Resource Group"
  value       = azurerm_resource_group.this.id
}