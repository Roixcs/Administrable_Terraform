# ============================================
# Azure Function Windows Module - Variables
# DISPATCHER
# ============================================

variable "functions" {
  description = "Lista de Azure Functions Windows a crear"
  type = list(object({
    name      = string
    enabled   = optional(bool, true) # ← Control de estado
    plan_type = string               # "consumption" o "basic"
    plan_name = optional(string)

    # Application Settings
    app_settings = optional(list(object({
      name         = string
      value        = string
      slot_setting = optional(bool, false)
    })), [])

    # Site Config
    always_on                   = optional(bool, false)
    dotnet_version              = optional(string, "v8.0")
    use_dotnet_isolated_runtime = optional(bool, true)

    # VNet Integration
    vnet_integration = optional(object({
      subnet_id = string
    }))

    # Identity
    identity_type = optional(string, "SystemAssigned") # SystemAssigned, UserAssigned
    identity_ids  = optional(list(string), [])

    # Application Insights
    application_insights_enabled = optional(bool, true)

    # Storage Account
    storage_account_name          = optional(string)
    storage_uses_managed_identity = optional(bool, false)
  }))

  validation {
    condition     = alltrue([for f in var.functions : can(regex("^[a-z0-9-]+$", f.name))])
    error_message = "Function names must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.functions) == length(distinct([for f in var.functions : f.name]))
    error_message = "Function names must be unique."
  }

  validation {
    condition     = alltrue([for f in var.functions : contains(["consumption", "basic"], f.plan_type)])
    error_message = "plan_type must be either 'consumption' or 'basic'."
  }
}

variable "location" {
  description = "Ubicación de los recursos"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
}

variable "workspace_id" {
  description = "ID del Log Analytics Workspace (opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}