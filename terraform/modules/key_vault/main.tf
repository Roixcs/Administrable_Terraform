# ============================================
# Key Vault Module - Main
# ============================================

resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name
  
  # Soft delete y purge protection
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  
  # RBAC Authorization (recomendado sobre Access Policies)
  enable_rbac_authorization = var.enable_rbac_authorization
  
  # Permisos para servicios de Azure
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  
  # Network ACLs
  network_acls {
    default_action = var.network_acls.default_action
    bypass         = var.network_acls.bypass
    ip_rules       = var.network_acls.ip_rules
  }
  
  tags = var.tags
  
  lifecycle {
    prevent_destroy = false  # Cambiar a true en producción
  }
}

# ============================================
# Key Vault Secrets (Opcional)
# ============================================
# NOTA: Para crear secretos con RBAC, necesitas el role assignment primero
# Esto es solo un ejemplo básico. En producción, usa RBAC roles.

resource "azurerm_key_vault_secret" "this" {
  for_each = { for s in var.secrets : s.name => s }
  
  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id
  
  tags = var.tags
  
  depends_on = [azurerm_key_vault.this]
  
  lifecycle {
    ignore_changes = [value]  # No actualizar si el valor cambia fuera de Terraform
  }
}