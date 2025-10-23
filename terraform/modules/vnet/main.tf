# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = length(var.address_space) > 0 ? var.address_space : ["10.0.0.0/16"]  # ✅ Default si está vacío
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null
  
  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.create_vnet ? var.subnets : {}
  
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = each.value.address_prefixes
  
  # Service Endpoints
  service_endpoints = length(each.value.service_endpoints) > 0 ? each.value.service_endpoints : null
  
  # Private Endpoint Policies
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  
  # Delegación (solo si está configurada)
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
  
  depends_on = [azurerm_virtual_network.vnet]
}