# ============================================
# Cosmos DB Module - Main
# SINGLE Account + DISPATCHER Databases/Containers
# ============================================

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "this" {
  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind
  
  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? var.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? var.max_staleness_prefix : null
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
  
  # Backup (solo si no es serverless)
  dynamic "backup" {
    for_each = !var.enable_serverless && var.backup_enabled ? [1] : []
    content {
      type                = var.backup_type
      interval_in_minutes = var.backup_interval_in_minutes
      retention_in_hours  = var.backup_retention_in_hours
    }
  }
  
  tags = var.tags
  
  lifecycle {
    prevent_destroy = false  # Cambiar a true en producción
  }
}

# Cosmos DB SQL Databases
resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = { for db in var.databases : db.name => db }
  
  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  
  # Throughput solo si NO es serverless Y se especifica a nivel DB
  throughput = var.enable_serverless ? null : each.value.throughput
}

# Flatten containers de todas las databases
locals {
  containers = flatten([
    for db in var.databases : [
      for container in db.containers : {
        db_name            = db.name
        container_name     = container.name
        partition_keys     = container.partition_keys
        throughput         = container.throughput
        default_ttl        = container.default_ttl
        unique_keys        = container.unique_keys
        indexing_policy    = container.indexing_policy
      }
    ]
  ])
  
  containers_map = {
    for container in local.containers :
    "${container.db_name}/${container.container_name}" => container
  }
}

# Cosmos DB SQL Containers
resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = local.containers_map
  
  name                = each.value.container_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this[each.value.db_name].name
  
  partition_key_paths   = each.value.partition_keys
  partition_key_version = 2
  default_ttl           = each.value.default_ttl
  
  # Throughput solo si NO es serverless Y se especifica
  throughput = var.enable_serverless ? null : each.value.throughput
  
  # Unique Keys
  dynamic "unique_key" {
    for_each = each.value.unique_keys != null ? each.value.unique_keys : []
    content {
      paths = unique_key.value.paths
    }
  }
  
  # Indexing Policy
  indexing_policy {
    indexing_mode = each.value.indexing_policy != null ? each.value.indexing_policy.indexing_mode : "consistent"
    
    # Included paths
    dynamic "included_path" {
      for_each = each.value.indexing_policy != null && each.value.indexing_policy.included_paths != null ? each.value.indexing_policy.included_paths : ["/*"]
      content {
        path = included_path.value
      }
    }
    
    # Excluded paths
    dynamic "excluded_path" {
      for_each = each.value.indexing_policy != null && each.value.indexing_policy.excluded_paths != null ? each.value.indexing_policy.excluded_paths : []
      content {
        path = excluded_path.value
      }
    }
    
    # Composite indexes
    dynamic "composite_index" {
      for_each = each.value.indexing_policy != null && each.value.indexing_policy.composite_indexes != null ? each.value.indexing_policy.composite_indexes : []
      content {
        dynamic "index" {
          for_each = composite_index.value
          content {
            path  = index.value.path
            order = index.value.order
          }
        }
      }
    }
  }
}

# Flatten stored procedures de todos los containers
locals {
  stored_procedures = flatten([
    for db in var.databases : [
      for container in db.containers : [
        for sp in container.stored_procedures != null ? container.stored_procedures : [] : {
          db_name        = db.name
          container_name = container.name
          sp_name        = sp.name
          sp_body        = sp.body
        }
      ]
    ]
  ])
  
  stored_procedures_map = {
    for sp in local.stored_procedures :
    "${sp.db_name}/${sp.container_name}/${sp.sp_name}" => sp
  }
}

# Stored Procedures (opcional)
resource "azurerm_cosmosdb_sql_stored_procedure" "this" {
  for_each = local.stored_procedures_map
  
  name                = each.value.sp_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this[each.value.db_name].name
  container_name      = azurerm_cosmosdb_sql_container.this["${each.value.db_name}/${each.value.container_name}"].name
  body                = each.value.sp_body
}