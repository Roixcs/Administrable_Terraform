# ============================================
# Resource Group Module - Variables
# ============================================

variable "name" {
  description = "Nombre del Resource Group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "El nombre solo puede contener letras, números, guiones y guiones bajos."
  }
}

variable "location" {
  description = "Ubicación de Azure para el Resource Group"
  type        = string

  validation {
    condition     = contains(["East US", "East US 2", "West US", "West US 2", "Central US", "North Europe", "West Europe"], var.location)
    error_message = "Location debe ser una región válida de Azure."
  }
}

variable "tags" {
  description = "Tags para el Resource Group"
  type        = map(string)
  default     = {}
}
