# ============================================
# Resource Group Module - Main
# ============================================

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    prevent_destroy = false # Cambiar a true en producción
  }
}

# Output local para debugging (opcional)
output "debug_info" {
  value = {
    name     = azurerm_resource_group.this.name
    location = azurerm_resource_group.this.location
    id       = azurerm_resource_group.this.id
  }
  description = "Información de debugging del Resource Group"
}