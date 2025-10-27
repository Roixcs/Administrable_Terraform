# ============================================
# API Management Module - Main
# ============================================

resource "azurerm_api_management" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name

  # Virtual Network (solo si no es Consumption)
  virtual_network_type = var.virtual_network_type

  # VNet Configuration (solo para Developer, Basic, Standard, Premium)
  dynamic "virtual_network_configuration" {
    for_each = var.virtual_network_configuration != null ? [var.virtual_network_configuration] : []
    content {
      subnet_id = virtual_network_configuration.value.subnet_id
    }
  }

  # Public IP (solo para External VNet mode)
  public_ip_address_id = var.public_ip_address_id

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Cambiar a true en producción
  }
}