# ============================================
# VNet Module - Variables
# ============================================

variable "create_vnet" {
  description = "Crear nueva VNet (false = solo crear subnets en VNet existente)"
  type        = bool
  default     = false
}

variable "vnet_name" {
  description = "Nombre de la Virtual Network (existente o nueva)"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group (donde está o estará la VNet)"
  type        = string
}

variable "location" {
  description = "Location de Azure (solo si create_vnet = true)"
  type        = string
}

variable "address_space" {
  description = "Espacio de direcciones para la VNet (solo si create_vnet = true)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.address_space : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}\\/[0-9]{1,2}$", cidr))
    ])
    error_message = "Los address_space deben estar en formato CIDR válido (ej: 10.0.0.0/16)."
  }
}

variable "dns_servers" {
  description = "Servidores DNS personalizados (opcional)"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Subnets a crear (en VNet nueva o existente)"
  type = map(object({
    name             = string
    address_prefixes = list(string)

    # Service Endpoints
    service_endpoints = optional(list(string), [])

    # Delegación (para Azure Functions, App Services, etc.)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))

    # Private Endpoint Policies
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  default = {}
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}