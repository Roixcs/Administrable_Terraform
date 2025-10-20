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
  
  consistency_policy {
    consistency_level = var.consistency_level
  }
  
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
  
  #enable_automatic_failover = var.enable_automatic_failover
  
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