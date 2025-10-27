# ============================================
# Azure Front Door Module - Main
# ============================================
# Standard SKU optimizado para Static Websites
# ============================================

# Front Door Profile
resource "azurerm_cdn_frontdoor_profile" "profile" {
  count                    = var.create_front_door ? 1 : 0
  name                     = var.name
  resource_group_name      = var.resource_group_name
  sku_name                 = var.sku_name
  response_timeout_seconds = var.response_timeout_seconds

  tags = var.tags
}

# Front Door Endpoints
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  for_each = var.create_front_door ? var.endpoints : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile[0].id
  enabled                  = each.value.enabled

  tags = var.tags
}

# Front Door Origin Groups
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  for_each = var.create_front_door ? var.origin_groups : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile[0].id
  session_affinity_enabled = each.value.session_affinity_enabled

  load_balancing {
    additional_latency_in_milliseconds = each.value.load_balancing.additional_latency_in_milliseconds
    sample_size                        = each.value.load_balancing.sample_size
    successful_samples_required        = each.value.load_balancing.successful_samples_required
  }

  dynamic "health_probe" {
    for_each = each.value.health_probe != null ? [each.value.health_probe] : []
    content {
      interval_in_seconds = health_probe.value.interval_in_seconds
      path                = health_probe.value.path
      protocol            = health_probe.value.protocol
      request_type        = health_probe.value.request_type
    }
  }
}

# Front Door Origins
resource "azurerm_cdn_frontdoor_origin" "origin" {
  for_each = var.create_front_door ? var.origins : {}

  name                          = each.value.name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group[each.value.origin_group_key].id
  enabled                       = each.value.enabled

  host_name                      = each.value.host_name
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
  priority                       = each.value.priority
  weight                         = each.value.weight

  dynamic "private_link" {
    for_each = each.value.private_link != null ? [each.value.private_link] : []
    content {
      request_message        = private_link.value.request_message
      target_type            = private_link.value.target_type
      location               = private_link.value.location
      private_link_target_id = private_link.value.private_link_target_id
    }
  }
}

# Front Door Custom Domains
resource "azurerm_cdn_frontdoor_custom_domain" "custom_domain" {
  for_each = var.create_front_door ? var.custom_domains : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile[0].id
  host_name                = each.value.host_name

  tls {
    certificate_type    = each.value.tls.certificate_type
    minimum_tls_version = each.value.tls.minimum_tls_version
  }
}

# Front Door Rule Set (para rewrites y headers de seguridad)
resource "azurerm_cdn_frontdoor_rule_set" "rule_set" {
  for_each = var.create_front_door ? var.rule_sets : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.profile[0].id
}

# Front Door Rules (rewrites, redirects, headers)
resource "azurerm_cdn_frontdoor_rule" "rule" {
  for_each = var.create_front_door ? var.rules : {}

  name                      = each.value.name
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.rule_set[each.value.rule_set_key].id
  order                     = each.value.order
  behavior_on_match         = each.value.behavior_on_match

  # Conditions
  dynamic "conditions" {
    for_each = each.value.conditions != null ? [each.value.conditions] : []
    content {
      # Request URI Condition
      dynamic "request_uri_condition" {
        for_each = try(conditions.value.request_uri, null) != null ? [conditions.value.request_uri] : []
        content {
          operator         = request_uri_condition.value.operator
          negate_condition = try(request_uri_condition.value.negate_condition, false)
          match_values     = try(request_uri_condition.value.match_values, [])
          transforms       = try(request_uri_condition.value.transforms, [])
        }
      }

      # URL Path Condition
      dynamic "url_path_condition" {
        for_each = try(conditions.value.url_path, null) != null ? [conditions.value.url_path] : []
        content {
          operator         = url_path_condition.value.operator
          negate_condition = try(url_path_condition.value.negate_condition, false)
          match_values     = try(url_path_condition.value.match_values, [])
          transforms       = try(url_path_condition.value.transforms, [])
        }
      }

      # URL File Extension Condition
      dynamic "url_file_extension_condition" {
        for_each = try(conditions.value.url_file_extension, null) != null ? [conditions.value.url_file_extension] : []
        content {
          operator         = url_file_extension_condition.value.operator
          negate_condition = try(url_file_extension_condition.value.negate_condition, false)
          match_values     = try(url_file_extension_condition.value.match_values, [])
          transforms       = try(url_file_extension_condition.value.transforms, [])
        }
      }
    }
  }

  # Actions
  actions {
    # URL Rewrite
    dynamic "url_rewrite_action" {
      for_each = try(each.value.actions.url_rewrite, null) != null ? [each.value.actions.url_rewrite] : []
      content {
        source_pattern          = url_rewrite_action.value.source_pattern
        destination             = url_rewrite_action.value.destination
        preserve_unmatched_path = try(url_rewrite_action.value.preserve_unmatched_path, false)
      }
    }

    # URL Redirect
    dynamic "url_redirect_action" {
      for_each = try(each.value.actions.url_redirect, null) != null ? [each.value.actions.url_redirect] : []
      content {
        redirect_type        = url_redirect_action.value.redirect_type
        redirect_protocol    = try(url_redirect_action.value.redirect_protocol, "Https")
        destination_hostname = try(url_redirect_action.value.destination_hostname, null)
        destination_path     = try(url_redirect_action.value.destination_path, null)
        query_string         = try(url_redirect_action.value.query_string, null)
        destination_fragment = try(url_redirect_action.value.destination_fragment, null)
      }
    }

    # Response Header Actions (Security Headers)
    dynamic "response_header_action" {
      for_each = try(each.value.actions.response_headers, {})
      content {
        header_action = response_header_action.value.action
        header_name   = response_header_action.key
        value         = try(response_header_action.value.value, null)
      }
    }

    # Request Header Actions
    dynamic "request_header_action" {
      for_each = try(each.value.actions.request_headers, {})
      content {
        header_action = request_header_action.value.action
        header_name   = request_header_action.key
        value         = try(request_header_action.value.value, null)
      }
    }
  }
}

# Front Door Routes
resource "azurerm_cdn_frontdoor_route" "route" {
  for_each = var.create_front_door ? var.routes : {}

  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint[each.value.endpoint_key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group[each.value.origin_group_key].id
  cdn_frontdoor_origin_ids      = [for key in each.value.origin_keys : azurerm_cdn_frontdoor_origin.origin[key].id]

  patterns_to_match      = each.value.patterns_to_match
  supported_protocols    = each.value.supported_protocols
  forwarding_protocol    = each.value.forwarding_protocol
  https_redirect_enabled = each.value.https_redirect_enabled
  enabled                = each.value.enabled
  link_to_default_domain = each.value.link_to_default_domain

  # Custom Domains
  cdn_frontdoor_custom_domain_ids = length(each.value.custom_domains) > 0 ? [
    for domain_key in each.value.custom_domains :
    azurerm_cdn_frontdoor_custom_domain.custom_domain[domain_key].id
  ] : []

  # Rule Sets
  cdn_frontdoor_rule_set_ids = length(each.value.rule_set_keys) > 0 ? [
    for rule_set_key in each.value.rule_set_keys :
    azurerm_cdn_frontdoor_rule_set.rule_set[rule_set_key].id
  ] : []

  # Cache Configuration
  dynamic "cache" {
    for_each = each.value.cache != null ? [each.value.cache] : []
    content {
      query_string_caching_behavior = cache.value.query_string_caching_behavior
      query_strings                 = cache.value.query_strings
      compression_enabled           = cache.value.compression_enabled
      content_types_to_compress     = cache.value.content_types_to_compress
    }
  }

  depends_on = [
    azurerm_cdn_frontdoor_origin.origin,
    azurerm_cdn_frontdoor_origin_group.origin_group,
    azurerm_cdn_frontdoor_rule.rule
  ]
}