# ============================================
# Azure Function Linux Module - Variables
# DISPATCHER
# ============================================

variable "functions" {
  description = "Lista de Azure Functions Linux (Flex Consumption) a crear"
  type = list(object({
    name    = string
    enabled = optional(bool, true) # ← Nueva propiedad
    runtime = optional(string, "dotnet-isolated")
    version = optional(string, "8.0")
    app_settings = optional(list(object({
      name         = string
      value        = string
      slot_setting = optional(bool, false)
    })), [])
    instance_memory_mb     = optional(number, 2048)
    maximum_instance_count = optional(number, 100)
  }))

  validation {
    condition     = alltrue([for f in var.functions : can(regex("^[a-z0-9-]+$", f.name))])
    error_message = "Function names must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.functions) == length(distinct([for f in var.functions : f.name]))
    error_message = "Function names must be unique."
  }
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "resource_group_id" {
  description = "ID del Resource Group (para azapi)"
  type        = string
}

variable "location" {
  description = "Location de Azure"
  type        = string
}

variable "workspace_id" {
  description = "ID del Log Analytics Workspace para Application Insights"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}