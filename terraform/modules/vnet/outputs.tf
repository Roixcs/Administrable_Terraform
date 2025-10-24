# ============================================
# VNet Module - Outputs
# ============================================

output "vnet_id" {
  description = "ID de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].id : data.azurerm_virtual_network.existing[0].id
}

output "vnet_name" {
  description = "Nombre de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.existing[0].name
}

output "vnet_address_space" {
  description = "Espacio de direcciones de la VNet"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].address_space : data.azurerm_virtual_network.existing[0].address_space
}

output "vnet_location" {
  description = "Ubicación de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].location : data.azurerm_virtual_network.existing[0].location
}

output "subnet_ids" {
  description = "Mapa de IDs de las subnets creadas"
  value = {
    for key, subnet in azurerm_subnet.subnets : key => subnet.id
  }
}

output "subnet_names" {
  description = "Mapa de nombres de las subnets"
  value = {
    for key, subnet in azurerm_subnet.subnets : key => subnet.name
  }
}

output "subnet_address_prefixes" {
  description = "Mapa de address prefixes de las subnets"
  value = {
    for key, subnet in azurerm_subnet.subnets : key => subnet.address_prefixes
  }
}

output "network_configuration" {
  description = "Configuración completa de la red"
  value = {
    vnet = {
      id            = var.create_vnet ? azurerm_virtual_network.vnet[0].id : data.azurerm_virtual_network.existing[0].id
      name          = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.existing[0].name
      address_space = var.create_vnet ? azurerm_virtual_network.vnet[0].address_space : data.azurerm_virtual_network.existing[0].address_space
    }
    subnets = {
      for key, subnet in azurerm_subnet.subnets : key => {
        id               = subnet.id
        name             = subnet.name
        address_prefixes = subnet.address_prefixes
      }
    }
  }
}