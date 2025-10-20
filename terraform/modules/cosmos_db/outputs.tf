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

output "primary_connection_string" {
  description = "Primary connection string de Cosmos DB"
  value       = "AccountEndpoint=${azurerm_cosmosdb_account.this.endpoint};AccountKey=${azurerm_cosmosdb_account.this.primary_key};"
  sensitive   = true
}

output "database_name" {
  description = "Nombre de la database"
  value       = azurerm_cosmosdb_sql_database.this.name
}

output "containers" {
  description = "Containers creados"
  value = {
    for name, container in azurerm_cosmosdb_sql_container.this : name => {
      id   = container.id
      name = container.name
    }
  }
}