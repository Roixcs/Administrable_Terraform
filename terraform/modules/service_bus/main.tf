# ============================================
# Service Bus Module - Main
# SINGLE namespace + DISPATCHER queues/topics
# ============================================

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "this" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Cambiar a true en producción
  }
}

# Queues - SIN enable_batched_operations
resource "azurerm_servicebus_queue" "this" {
  for_each = { for q in var.queues : q.name => q }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  dead_lettering_on_message_expiration    = each.value.enable_dead_lettering_on_message_expiration
  max_delivery_count                      = each.value.max_delivery_count
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  status                                  = each.value.enabled ? "Active" : "Disabled"
}

# Topics - SIN enable_batched_operations
resource "azurerm_servicebus_topic" "this" {
  for_each = { for t in var.topics : t.name => t }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  status                                  = each.value.enabled ? "Active" : "Disabled"
}

# Topic Subscriptions
resource "azurerm_servicebus_subscription" "this" {
  for_each = merge([
    for topic in var.topics : {
      for sub in topic.subscriptions :
      "${topic.name}/${sub.name}" => {
        topic_name                                  = topic.name
        subscription_name                           = sub.name
        max_delivery_count                          = sub.max_delivery_count
        enable_dead_lettering_on_message_expiration = sub.enable_dead_lettering_on_message_expiration
        enabled                                     = sub.enabled
      }
    }
  ]...)

  name                                 = each.value.subscription_name
  topic_id                             = azurerm_servicebus_topic.this[each.value.topic_name].id
  max_delivery_count                   = each.value.max_delivery_count
  dead_lettering_on_message_expiration = each.value.enable_dead_lettering_on_message_expiration
  status                               = each.value.enabled ? "Active" : "Disabled" # ← Control de estado
}