# ============================================
# Service Bus Module - Outputs
# ============================================

output "namespace_id" {
  description = "ID del Service Bus Namespace"
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Nombre del Service Bus Namespace"
  value       = azurerm_servicebus_namespace.this.name
}

output "primary_connection_string" {
  description = "Primary Connection String del Service Bus"
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "queues" {
  description = "Información de las queues creadas"
  value = {
    for name, queue in azurerm_servicebus_queue.this : name => {
      id      = queue.id
      name    = queue.name
      status  = queue.status
    }
  }
}

output "topics" {
  description = "Información de los topics creados"
  value = {
    for name, topic in azurerm_servicebus_topic.this : name => {
      id     = topic.id
      name   = topic.name
      status = topic.status
    }
  }
}

output "subscriptions" {
  description = "Información de las subscriptions creadas"
  value = {
    for key, sub in azurerm_servicebus_subscription.this : key => {
      id     = sub.id
      name   = sub.name
      status = sub.status
    }
  }
}