variable "functions" {
  description = "Lista de Azure Functions Linux (Flex Consumption) a crear"
  type = list(object({
    name        = string
    plan_type   = string  # "FlexConsumption"
    plan_name   = optional(string)
    create      = bool
    app_settings = list(object({
      name        = string
      value       = string
      slotSetting = bool
    }))
  }))
}

variable "location" {
  description = "Ubicación de los recursos"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "resource_group_id" {
  description = "Resource ID del Resource Group"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID (para calcular nombre del workspace default)"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID del Log Analytics Workspace (opcional, se reutiliza el default si no se especifica)"
  type        = string
  default     = null
}

variable "reuse_existing_workspace" {
  description = "Si true, intenta reutilizar el workspace default de Azure"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}