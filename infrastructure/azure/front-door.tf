locals {
  frontend_host                    = "${local.project}.azurefd.net"
  frontend_endpoint_name           = replace(local.frontend_host, ".", "")
  backend_pool_load_balancing_name = "${local.project}-backend-pool-load-balancing"
  backend_pool_health_probe_name   = "${local.project}-backend-pool-health-probe"
}

resource "azurerm_frontdoor" "example" {
  name                                         = local.project
  resource_group_name                          = azurerm_resource_group.example.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "fd-to-lb"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.frontend_endpoint_name]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = azurerm_public_ip.example.name
    }
  }

  backend_pool_load_balancing {
    name = local.backend_pool_load_balancing_name
  }

  backend_pool_health_probe {
    name = local.backend_pool_health_probe_name
  }

  backend_pool {
    name = azurerm_public_ip.example.name
    backend {
      enabled     = true
      address     = azurerm_public_ip.example.ip_address
      host_header = local.frontend_host
      http_port   = 80
      https_port  = 443
    }
    load_balancing_name = local.backend_pool_load_balancing_name
    health_probe_name   = local.backend_pool_health_probe_name
  }

  frontend_endpoint {
    name      = local.frontend_endpoint_name
    host_name = local.frontend_host
  }
}

