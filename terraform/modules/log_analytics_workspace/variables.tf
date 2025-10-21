variable "create_log_analytics" {
  description = "Indica si se crea el Log Analytics Workspace"
  type        = bool
  default     = false
}

variable "name" {
  description = "Nombre del Log Analytics Workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Ubicación de los recursos"
  type        = string
}

variable "sku" {
  description = "SKU del Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "El SKU debe ser uno de: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018"
  }
}

variable "retention_in_days" {
  description = "Días de retención de datos (30-730 días para PerGB2018)"
  type        = number
  default     = 30
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "La retención debe estar entre 30 y 730 días"
  }
}

variable "daily_quota_gb" {
  description = "Límite de ingesta diaria en GB (-1 para ilimitado)"
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Habilitar ingesta desde internet"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Habilitar consultas desde internet"
  type        = bool
  default     = true
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Capacidad de reserva en GB por día (solo para CapacityReservation SKU)"
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}