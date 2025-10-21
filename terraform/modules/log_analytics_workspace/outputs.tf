# Log Analytics Workspace Outputs
output "id" {
  description = "ID del Log Analytics Workspace"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.workspace[0].id : null
}

output "name" {
  description = "Nombre del Log Analytics Workspace"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.workspace[0].name : var.name
}

output "workspace_id" {
  description = "Workspace ID (GUID) del Log Analytics Workspace"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.workspace[0].workspace_id : null
}

output "primary_shared_key" {
  description = "Primary Shared Key del Log Analytics Workspace"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.workspace[0].primary_shared_key : null
  sensitive   = true
}

output "secondary_shared_key" {
  description = "Secondary Shared Key del Log Analytics Workspace"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.workspace[0].secondary_shared_key : null
  sensitive   = true
}

output "location" {
  description = "Ubicación del Log Analytics Workspace"
  value       = var.create_log_analytics ? azurerm_log_analytics_workspace.workspace[0].location : null
}