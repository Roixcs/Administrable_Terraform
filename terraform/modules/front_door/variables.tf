# ============================================
# Azure Front Door Module - Variables
# ============================================

variable "create_front_door" {
  description = "Indica si se crea el Front Door"
  type        = bool
  default     = false
}

variable "name" {
  description = "Nombre del Front Door Profile"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.name))
    error_message = "El nombre debe empezar y terminar con alfanumérico, puede contener guiones."
  }
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "sku_name" {
  description = "SKU del Front Door (Standard_AzureFrontDoor o Premium_AzureFrontDoor)"
  type        = string
  default     = "Standard_AzureFrontDoor"
  
  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "El SKU debe ser Standard_AzureFrontDoor o Premium_AzureFrontDoor"
  }
}

variable "response_timeout_seconds" {
  description = "Timeout de respuesta en segundos (16-240)"
  type        = number
  default     = 120
  
  validation {
    condition     = var.response_timeout_seconds >= 16 && var.response_timeout_seconds <= 240
    error_message = "El timeout debe estar entre 16 y 240 segundos"
  }
}

# ============================================
# Endpoints
# ============================================

variable "endpoints" {
  description = "Lista de endpoints del Front Door"
  type = map(object({
    name    = string
    enabled = optional(bool, true)
  }))
  default = {}
}

# ============================================
# Origin Groups
# ============================================

variable "origin_groups" {
  description = "Configuración de origin groups"
  type = map(object({
    name                     = string
    session_affinity_enabled = optional(bool, false)
    
    load_balancing = optional(object({
      additional_latency_in_milliseconds = optional(number, 50)
      sample_size                        = optional(number, 4)
      successful_samples_required        = optional(number, 3)
    }), {})
    
    health_probe = optional(object({
      interval_in_seconds = number
      path                = optional(string, "/")
      protocol            = string
      request_type        = optional(string, "HEAD")
    }))
  }))
  default = {}
}

# ============================================
# Origins
# ============================================

variable "origins" {
  description = "Configuración de origins"
  type = map(object({
    name                           = string
    origin_group_key               = string
    host_name                      = string
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    certificate_name_check_enabled = optional(bool, true)
    enabled                        = optional(bool, true)
    priority                       = optional(number, 1)
    weight                         = optional(number, 1000)
    
    private_link = optional(object({
      request_message        = optional(string)
      target_type            = optional(string)
      location               = string
      private_link_target_id = string
    }))
  }))
  default = {}
}

# ============================================
# Routes
# ============================================

variable "routes" {
  description = "Configuración de routes (rutas)"
  type = map(object({
    name                   = string
    endpoint_key           = string
    origin_group_key       = string
    origin_keys            = list(string)
    patterns_to_match      = list(string)
    supported_protocols    = list(string)
    forwarding_protocol    = optional(string, "HttpsOnly")
    https_redirect_enabled = optional(bool, true)
    enabled                = optional(bool, true)
    link_to_default_domain = optional(bool, true)
    
    cache = optional(object({
      query_string_caching_behavior = optional(string, "IgnoreQueryString")
      query_strings                 = optional(list(string), [])
      compression_enabled           = optional(bool, true)
      content_types_to_compress     = optional(list(string), [])
    }))
    
    custom_domains  = optional(list(string), [])
    rule_set_keys   = optional(list(string), [])
  }))
  default = {}
}

# ============================================
# Custom Domains
# ============================================

variable "custom_domains" {
  description = "Dominios personalizados"
  type = map(object({
    name      = string
    host_name = string
    
    tls = optional(object({
      certificate_type    = optional(string, "ManagedCertificate")
      minimum_tls_version = optional(string, "TLS12")
    }), {
      certificate_type    = "ManagedCertificate"
      minimum_tls_version = "TLS12"
    })
  }))
  default = {}
}

# ============================================
# Rule Sets (para rewrites y headers)
# ============================================

variable "rule_sets" {
  description = "Rule Sets para rewrites, redirects y headers"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "rules" {
  description = "Reglas para rewrites, redirects y headers de seguridad"
  type = map(object({
    name              = string
    rule_set_key      = string
    order             = number
    behavior_on_match = optional(string, "Continue")
    
    conditions = optional(object({
      request_uri = optional(object({
        operator         = string
        match_values     = optional(list(string), [])
        negate_condition = optional(bool, false)
        transforms       = optional(list(string), [])
      }))
      
      url_path = optional(object({
        operator         = string
        match_values     = optional(list(string), [])
        negate_condition = optional(bool, false)
        transforms       = optional(list(string), [])
      }))
      
      url_file_extension = optional(object({
        operator         = string
        match_values     = list(string)
        negate_condition = optional(bool, false)
        transforms       = optional(list(string), [])
      }))
    }))
    
    actions = object({
      url_rewrite = optional(object({
        source_pattern          = string
        destination             = string
        preserve_unmatched_path = optional(bool, false)
      }))
      
      url_redirect = optional(object({
        redirect_type        = string
        redirect_protocol    = optional(string, "Https")
        destination_hostname = optional(string)
        destination_path     = optional(string)
        query_string         = optional(string)
        destination_fragment = optional(string)
      }))
      
      response_headers = optional(map(object({
        action = string
        value  = optional(string)
      })), {})
      
      request_headers = optional(map(object({
        action = string
        value  = optional(string)
      })), {})
    })
  }))
  default = {}
}

# ============================================
# Tags
# ============================================

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}