# ============================================
# API Management Module - Variables
# ============================================

variable "name" {
  description = "Nombre del API Management"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.name))
    error_message = "El nombre debe empezar con letra y solo contener letras, números y guiones."
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

variable "publisher_name" {
  description = "Nombre del publisher"
  type        = string
}

variable "publisher_email" {
  description = "Email del publisher"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.publisher_email))
    error_message = "Debe ser un email válido."
  }
}

variable "sku_name" {
  description = "SKU del API Management (Consumption_0, Developer_1, Basic_1, Standard_1, Premium_1)"
  type        = string
  default     = "Consumption_0"
  
  validation {
    condition = can(regex("^(Consumption_0|Developer_1|Basic_[12]|Standard_[124]|Premium_[1-9][0-9]*)$", var.sku_name))
    error_message = "SKU inválido. Usa: Consumption_0, Developer_1, Basic_1-2, Standard_1/2/4, Premium_1+."
  }
}

variable "virtual_network_type" {
  description = "Tipo de integración con VNet (None, External, Internal)"
  type        = string
  default     = "None"
  
  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "virtual_network_type debe ser: None, External o Internal."
  }
}

variable "virtual_network_configuration" {
  description = "Configuración de VNet (solo para Developer, Basic, Standard, Premium)"
  type = object({
    subnet_id = string
  })
  default = null
}

variable "public_ip_address_id" {
  description = "ID de la Public IP para External VNet (opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para API Management"
  type        = map(string)
  default     = {}
}