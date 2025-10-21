# Front Door Profile Outputs
output "profile_id" {
  description = "ID del Front Door Profile"
  value       = var.create_front_door ? azurerm_cdn_frontdoor_profile.profile[0].id : null
}

output "profile_name" {
  description = "Nombre del Front Door Profile"
  value       = var.create_front_door ? azurerm_cdn_frontdoor_profile.profile[0].name : var.name
}

output "resource_guid" {
  description = "Resource GUID del Front Door Profile"
  value       = var.create_front_door ? azurerm_cdn_frontdoor_profile.profile[0].resource_guid : null
}

# Endpoints Outputs
output "endpoint_ids" {
  description = "Mapa de IDs de los endpoints"
  value = {
    for key, endpoint in azurerm_cdn_frontdoor_endpoint.endpoint : key => endpoint.id
  }
}

output "endpoint_host_names" {
  description = "Mapa de host names de los endpoints"
  value = {
    for key, endpoint in azurerm_cdn_frontdoor_endpoint.endpoint : key => endpoint.host_name
  }
}

# Origin Groups Outputs
output "origin_group_ids" {
  description = "Mapa de IDs de los origin groups"
  value = {
    for key, og in azurerm_cdn_frontdoor_origin_group.origin_group : key => og.id
  }
}

# Origins Outputs
output "origin_ids" {
  description = "Mapa de IDs de los origins"
  value = {
    for key, origin in azurerm_cdn_frontdoor_origin.origin : key => origin.id
  }
}

# Custom Domains Outputs
output "custom_domain_ids" {
  description = "Mapa de IDs de los custom domains"
  value = {
    for key, domain in azurerm_cdn_frontdoor_custom_domain.custom_domain : key => domain.id
  }
}

# Routes Outputs
output "route_ids" {
  description = "Mapa de IDs de las routes"
  value = {
    for key, route in azurerm_cdn_frontdoor_route.route : key => route.id
  }
}

# Complete Configuration Output
output "front_door_configuration" {
  description = "Configuración completa del Front Door"
  value = var.create_front_door ? {
    profile = {
      id            = azurerm_cdn_frontdoor_profile.profile[0].id
      name          = azurerm_cdn_frontdoor_profile.profile[0].name
      resource_guid = azurerm_cdn_frontdoor_profile.profile[0].resource_guid
    }
    endpoints = {
      for key, endpoint in azurerm_cdn_frontdoor_endpoint.endpoint : key => {
        id        = endpoint.id
        host_name = endpoint.host_name
      }
    }
  } : null
}