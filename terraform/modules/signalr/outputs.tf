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

output "secondary_connection_string" {
  description = "Secondary connection string"
  value       = azurerm_signalr_service.this.secondary_connection_string
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key"
  value       = azurerm_signalr_service.this.secondary_access_key
  sensitive   = true
}

output "public_port" {
  description = "Puerto público del SignalR"
  value       = azurerm_signalr_service.this.public_port
}

output "server_port" {
  description = "Puerto del servidor"
  value       = azurerm_signalr_service.this.server_port
}