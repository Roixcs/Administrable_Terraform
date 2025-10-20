# ============================================
# SignalR Service Module - Outputs
# ============================================

output "id" {
  description = "ID del SignalR Service"
  value       = azurerm_signalr_service.this.id
}

output "name" {
  description = "Nombre del SignalR Service"
  value       = azurerm_signalr_service.this.name
}

output "hostname" {
  description = "Hostname del SignalR Service"
  value       = azurerm_signalr_service.this.hostname
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_signalr_service.this.primary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_signalr_service.this.primary_access_key
  sensitive   = true
}