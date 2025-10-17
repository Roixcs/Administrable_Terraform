# ============================================
# Azure Function Linux Module - Variables
# ============================================

variable "functions" {
  description = "Lista de Azure Functions Linux (Flex Consumption) a crear"
  type = list(object({
    name    = string
    runtime = optional(string, "dotnet-isolated")
    version = optional(string, "8.0")
    app_settings = optional(list(object({
      name        = string
      value       = string
      slot_setting = optional(bool, false)
    })), [])
    instance_memory_mb       = optional(number, 2048)
    maximum_instance_count   = optional(number, 100)
  }))
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