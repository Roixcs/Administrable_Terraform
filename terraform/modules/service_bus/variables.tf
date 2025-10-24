# ============================================
# Service Bus Module - Variables
# ============================================

variable "namespace_name" {
  description = "Nombre del Service Bus Namespace"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", var.namespace_name))
    error_message = "El nombre debe tener 6-50 caracteres, empezar con letra, y solo contener letras, números y guiones."
  }
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "location" {
  description = "Location de Azure"
  type        = string
}

variable "sku" {
  description = "SKU del Service Bus (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU debe ser: Basic, Standard o Premium."
  }
}

variable "queues" {
  description = "Lista de queues a crear"
  type = list(object({
    name                                        = string
    enabled                                     = optional(bool, true)
    max_size_in_megabytes                       = optional(number, 1024)
    enable_dead_lettering_on_message_expiration = optional(bool, true)
    max_delivery_count                          = optional(number, 10)
    duplicate_detection_history_time_window     = optional(string, "PT10M")
  }))
  default = []
}

variable "topics" {
  description = "Lista de topics a crear con sus subscriptions"
  type = list(object({
    name                                    = string
    enabled                                 = optional(bool, true)
    max_size_in_megabytes                   = optional(number, 1024)
    duplicate_detection_history_time_window = optional(string, "PT10M")
    subscriptions = optional(list(object({
      name                                        = string
      enabled                                     = optional(bool, true)
      max_delivery_count                          = optional(number, 10)
      enable_dead_lettering_on_message_expiration = optional(bool, true)
    })), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags para el Service Bus"
  type        = map(string)
  default     = {}
}