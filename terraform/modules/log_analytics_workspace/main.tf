# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "workspace" {
  count               = var.create_log_analytics ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  
  reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day
  
  tags = var.tags
}