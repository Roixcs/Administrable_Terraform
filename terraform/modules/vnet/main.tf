# ============================================
# VNet Module - Main (VERSIÓN CORRECTA Y COMPLETA)
# ============================================
# 
# Este módulo soporta:
# - Crear una nueva VNet (create_vnet = true)
# - Usar una VNet existente (create_vnet = false)
# - Crear subnets en VNet nueva o existente
# - Delegación dinámica para servicios (Functions, App Services, etc.)
# - Service Endpoints configurables
# - Private Endpoint Policies
# ============================================

# ============================================
# Data Source: VNet Existente
# ============================================
# Se usa cuando create_vnet = false
# Permite crear subnets en una VNet que ya existe

# data "azurerm_virtual_network" "existing" {
#   count               = var.create_vnet ? 0 : 1
#   name                = var.vnet_name
#   resource_group_name = var.resource_group_name
# }

# Solo buscar VNet existente si NO se crea Y hay subnets para crear
# data "azurerm_virtual_network" "existing" {
#   count               = !var.create_vnet && length(var.subnets) > 0 ? 1 : 0  # ✅
#   name                = var.vnet_name
#   resource_group_name = var.resource_group_name
# }

# Solo buscar VNet existente si NO se crea Y hay subnets para crear
data "azurerm_virtual_network" "existing" {
  count               = !var.create_vnet && length(var.subnets) > 0 ? 1 : 0  # ✅
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

# ============================================
# Resource: Nueva VNet
# ============================================
# Se crea cuando create_vnet = true

resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Cambiar a true en producción
  }
}

# ============================================
# Resource: Subnets
# ============================================
# Se crean subnets en la VNet (nueva o existente)
# Soporta configuración dinámica de:
# - Service Endpoints
# - Delegación a servicios Azure
# - Private Endpoint Policies

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : data.azurerm_virtual_network.existing[0].name
  address_prefixes     = each.value.address_prefixes

  # Service Endpoints (opcional)
  # Ejemplos: Microsoft.Storage, Microsoft.KeyVault, Microsoft.Sql
  service_endpoints = length(each.value.service_endpoints) > 0 ? each.value.service_endpoints : null

  # Private Endpoint Policies
  # Nota: private_endpoint_network_policies_enabled está deprecated en algunas versiones
  # private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  # Delegación Dinámica
  # Permite delegar la subnet a servicios específicos de Azure
  # Ejemplo: Microsoft.Web/serverFarms para Functions
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

  # Dependencias
  # Asegura que la VNet exista antes de crear subnets
  depends_on = [
    azurerm_virtual_network.vnet,
    data.azurerm_virtual_network.existing
  ]
}