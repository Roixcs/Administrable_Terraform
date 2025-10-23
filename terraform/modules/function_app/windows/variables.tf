variable "functions" {
  description = "Lista de Azure Functions Windows a crear"
  type = list(object({
    name        = string
    plan_type   = string  # "consumption" o "basic"
    create      = bool
    plan_name   = optional(string)
    
    # Application Settings
    app_settings = optional(list(object({
      name         = string
      value        = string
      slot_setting = optional(bool, false)
    })), [])
    
    # Site Config
    always_on                              = optional(bool, false)
    dotnet_version                         = optional(string, "v8.0")
    use_dotnet_isolated_runtime           = optional(bool, true)
    
    # VNet Integration
    vnet_integration = optional(object({
      subnet_id = string
    }))
    
    # Identity
    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])
    
    # Application Insights
    application_insights_enabled = optional(bool, true)
    
    # Storage Account
    storage_account_name               = optional(string)
    storage_uses_managed_identity      = optional(bool, false)
  }))
  default = []
}

variable "location" {
  description = "Ubicación de los recursos"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID del Log Analytics Workspace (opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {}
}