# ============================================
# SignalR Service Module - Variables
# ============================================

variable "name" {
  description = "Nombre del SignalR Service"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "El nombre debe tener 2-63 caracteres, empezar con letra y solo contener letras, números y guiones."
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
  description = "SKU del SignalR Service"
  type        = string
  default     = "Free_F1"
  
  validation {
    condition     = can(regex("^(Free_F1|Standard_S1|Premium_P1)$", var.sku))
    error_message = "SKU debe ser: Free_F1, Standard_S1 o Premium_P1."
  }
}

variable "capacity" {
  description = "Capacidad del SignalR (Free=1, Standard=1-100, Premium=1-100)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 100
    error_message = "capacity debe estar entre 1 y 100."
  }
}

variable "service_mode" {
  description = "Modo del servicio (Default, Serverless, Classic)"
  type        = string
  default     = "Default"
  
  validation {
    condition     = contains(["Default", "Serverless", "Classic"], var.service_mode)
    error_message = "service_mode debe ser: Default, Serverless o Classic."
  }
}

variable "cors_allowed_origins" {
  description = "Lista de orígenes permitidos para CORS"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags para SignalR Service"
  type        = map(string)
  default     = {}
}