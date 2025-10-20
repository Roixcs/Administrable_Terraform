# ============================================
# Key Vault Module - Variables
# ============================================

variable "name" {
  description = "Nombre del Key Vault"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "El nombre debe tener 3-24 caracteres, empezar con letra, y solo contener letras, números y guiones."
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

variable "tenant_id" {
  description = "Tenant ID de Azure AD"
  type        = string
}

variable "sku_name" {
  description = "SKU del Key Vault (standard o premium)"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name debe ser: standard o premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Días de retención para soft delete (7-90)"
  type        = number
  default     = 7
  
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days debe estar entre 7 y 90."
  }
}

variable "purge_protection_enabled" {
  description = "Habilitar purge protection"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Usar RBAC en lugar de access policies"
  type        = bool
  default     = true
}

variable "enabled_for_deployment" {
  description = "Permitir Azure VMs obtener certificados"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Permitir Azure Disk Encryption obtener secrets"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Permitir Azure Resource Manager obtener secrets"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Configuración de Network ACLs"
  type = object({
    default_action = optional(string, "Allow")
    bypass         = optional(string, "AzureServices")
    ip_rules       = optional(list(string), [])
  })
  default = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

variable "tags" {
  description = "Tags para el Key Vault"
  type        = map(string)
  default     = {}
}