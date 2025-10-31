# ============================================
# SignalR Service Module - Main
# ============================================

resource "azurerm_signalr_service" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku # Free, Standard, Premium
    capacity = var.capacity
  }

  service_mode                  = var.service_mode
  public_network_access_enabled = var.public_network_access_enabled

  cors {
    allowed_origins = var.cors_allowed_origins
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Cambiar a true en producción
  }
}