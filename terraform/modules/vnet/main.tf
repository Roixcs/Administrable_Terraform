# ============================================
# VNet Module - Main
# ============================================

# Data source para VNet existente (si create_vnet = false)
data "azurerm_virtual_network" "existing" {
  count               = var.create_vnet ? 0 : 1
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

# Nueva VNet (si create_vnet = true)
resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  
  tags = var.tags
  
  lifecycle {
    prevent_destroy = false  # Cambiar a true en producción
  }
}

# Subnets (en VNet nueva o existente)
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
  
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.existing[0].name
  address_prefixes     = each.value.address_prefixes
  
  # Service Endpoints
  service_endpoints = length(each.value.service_endpoints) > 0 ? each.value.service_endpoints : null
  
  # Private Endpoint Policies
  #private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  
  # Delegación (para Azure Functions, App Services, etc.)
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
  
  depends_on = [
    azurerm_virtual_network.vnet,
    data.azurerm_virtual_network.existing
  ]
}
