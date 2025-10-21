variable "create_vnet" {
  description = "Indica si se crea la Virtual Network"
  type        = bool
  default     = false
}

variable "vnet_name" {
  description = "Nombre de la Virtual Network"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Ubicación de los recursos"
  type        = string
}

variable "address_space" {
  description = "Espacio de direcciones para la VNet (CIDR)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "Lista de servidores DNS personalizados (opcional)"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Configuración de subnets"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    
    # Delegación (opcional)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))
    
    # Private Endpoint Network Policies
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