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

# ============================================
# Network Configuration Outputs
# ============================================

output "public_network_access_enabled" {
  description = "Estado del acceso público"
  value       = azurerm_cosmosdb_account.this.public_network_access_enabled
}

output "private_endpoint_id" {
  description = "ID del Private Endpoint (si está habilitado)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.cosmos[0].id : null
}

output "private_endpoint_ip" {
  description = "IP privada del Private Endpoint (si está habilitado)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.cosmos[0].private_service_connection[0].private_ip_address : null
}