locals {
  fd_diagnostics = sort([
    "FrontdoorAccessLog",
    "FrontdoorWebApplicationFirewallLog"
  ])
}

resource "azurerm_monitor_diagnostic_setting" "frontdoor" {
  name                       = "diagnostics-frontdoor"
  target_resource_id         = azurerm_frontdoor.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.diagnostics.id

  dynamic "log" {
    for_each = local.fd_diagnostics
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}