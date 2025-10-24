# ============================================
# Cosmos DB Module - Outputs
# ============================================

output "account_id" {
  description = "ID de la cuenta de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.id
}

output "account_name" {
  description = "Nombre de la cuenta de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "Endpoint de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "primary_key" {
  description = "Primary key de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "Secondary key de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.secondary_key
  sensitive   = true
}

output "primary_readonly_key" {
  description = "Primary readonly key de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.primary_readonly_key
  sensitive   = true
}

output "connection_strings" {
  description = "Connection strings de Cosmos DB"
  value       = azurerm_cosmosdb_account.this.connection_strings
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string de Cosmos DB"
  value       = "AccountEndpoint=${azurerm_cosmosdb_account.this.endpoint};AccountKey=${azurerm_cosmosdb_account.this.primary_key};"
  sensitive   = true
}

output "databases" {
  description = "Databases creadas"
  value = {
    for name, db in azurerm_cosmosdb_sql_database.this : name => {
      id   = db.id
      name = db.name
    }
  }
}

output "containers" {
  description = "Containers creados por database"
  value = {
    for key, container in azurerm_cosmosdb_sql_container.this : key => {
      id              = container.id
      name            = container.name
      partition_keys  = container.partition_key_paths
      default_ttl     = container.default_ttl
    }
  }
}

output "stored_procedures" {
  description = "Stored Procedures creados"
  value = {
    for key, sp in azurerm_cosmosdb_sql_stored_procedure.this : key => {
      id   = sp.id
      name = sp.name
    }
  }
}