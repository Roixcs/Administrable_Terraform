# ============================================
# Cosmos DB Module - Main
# ============================================

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "this" {
  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind
  
  # Network Configuration
  public_network_access_enabled = var.public_network_access_enabled
  ip_range_filter              = length(var.ip_range_filter) > 0 ? join(",", var.ip_range_filter) : null
  
  # Consistencia
  consistency_policy {
    consistency_level = var.consistency_level
  }
  
  # Geo-replicación
  geo_location {
    location          = var.location
    failover_priority = 0
  }
  
  # Serverless capability
  dynamic "capabilities" {
    for_each = var.enable_serverless ? [1] : []
    content {
      name = "EnableServerless"
    }
  }
  
  # Virtual Network Rules
  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules
    content {
      id                                   = virtual_network_rule.value.subnet_id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_endpoint
    }
  }
  
  # Automatic Failover (solo si no es serverless)
  #enable_automatic_failover = var.enable_serverless ? false : var.enable_automatic_failover
  
  tags = var.tags
  
  lifecycle {
    prevent_destroy = false  # Cambiar a true en producción
  }
}

# Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  
  # Throughput solo si NO es serverless
  throughput = var.enable_serverless ? null : 400
}

# Containers
resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = { for c in var.containers : c.name => c }
  
  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name
  
  partition_key_paths    = each.value.partition_keys
  partition_key_version  = 2
  default_ttl            = each.value.default_ttl
  
  # Throughput solo si NO es serverless
  throughput = var.enable_serverless ? null : each.value.throughput
  
  indexing_policy {
    indexing_mode = "consistent"
    
    included_path {
      path = "/*"
    }
  }
}

# ============================================
# Private Endpoint (Opcional)
# ============================================

resource "azurerm_private_endpoint" "cosmos" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.account_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  
  private_service_connection {
    name                           = "${var.account_name}-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.this.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
  
  tags = var.tags
  
  depends_on = [azurerm_cosmosdb_account.this]
}