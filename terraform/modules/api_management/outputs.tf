# ============================================
# API Management Module - Outputs
# ============================================

output "id" {
  description = "ID del API Management"
  value       = azurerm_api_management.this.id
}

output "name" {
  description = "Nombre del API Management"
  value       = azurerm_api_management.this.name
}

output "gateway_url" {
  description = "Gateway URL del API Management"
  value       = azurerm_api_management.this.gateway_url
}

output "gateway_regional_url" {
  description = "Gateway Regional URL del API Management"
  value       = azurerm_api_management.this.gateway_regional_url
}

output "management_api_url" {
  description = "Management API URL"
  value       = azurerm_api_management.this.management_api_url
}

output "portal_url" {
  description = "Portal URL"
  value       = azurerm_api_management.this.portal_url
}

output "developer_portal_url" {
  description = "Developer Portal URL"
  value       = azurerm_api_management.this.developer_portal_url
}

output "public_ip_addresses" {
  description = "Public IP addresses del API Management"
  value       = azurerm_api_management.this.public_ip_addresses
}

output "private_ip_addresses" {
  description = "Private IP addresses del API Management (si aplica)"
  value       = azurerm_api_management.this.private_ip_addresses
}