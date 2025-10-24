# ============================================
# Storage Account Module - Outputs
# DISPATCHER
# ============================================

output "storage_accounts" {
  description = "Información de los Storage Accounts creados"
  value = {
    for name, sa in azurerm_storage_account.this : name => {
      id                    = sa.id
      name                  = sa.name
      primary_blob_endpoint = sa.primary_blob_endpoint
      primary_web_endpoint  = sa.primary_web_endpoint
      primary_access_key    = sa.primary_access_key
    }
  }
  sensitive = true
}

output "static_websites" {
  description = "Endpoints de Static Websites"
  value = {
    for name, website in azurerm_storage_account_static_website.this : name => {
      primary_web_endpoint = azurerm_storage_account.this[name].primary_web_endpoint
    }
  }
}

output "containers" {
  description = "Containers creados"
  value = {
    for key, container in azurerm_storage_container.this : key => {
      id   = container.id
      name = container.name
    }
  }
}

output "connection_strings" {
  description = "Connection Strings de los Storage Accounts"
  value = {
    for name, sa in azurerm_storage_account.this : name => sa.primary_connection_string
  }
  sensitive = true
}