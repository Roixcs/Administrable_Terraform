# Virtual Network Outputs
output "vnet_id" {
  description = "ID de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].id : null
}

output "vnet_name" {
  description = "Nombre de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].name : var.vnet_name
}

output "vnet_address_space" {
  description = "Espacio de direcciones de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].address_space : []
}

output "vnet_location" {
  description = "Ubicación de la Virtual Network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].location : null
}

# Subnets Outputs
output "subnet_ids" {
  description = "Mapa de IDs de las subnets"
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

# Complete Network Configuration Output
output "network_configuration" {
  description = "Configuración completa de la red (para referencia)"
  value = var.create_vnet ? {
    vnet = {
      id            = azurerm_virtual_network.vnet[0].id
      name          = azurerm_virtual_network.vnet[0].name
      address_space = azurerm_virtual_network.vnet[0].address_space
      location      = azurerm_virtual_network.vnet[0].location
    }
    subnets = {
      for key, subnet in azurerm_subnet.subnets : key => {
        id               = subnet.id
        name             = subnet.name
        address_prefixes = subnet.address_prefixes
      }
    }
  } : null
}