locals {
  backend_pool_health_probe_name   = "${local.project}-backend-pool-health-probe"
  backend_pool_load_balancing_name = "${local.project}-backend-pool-load-balancing"
  backend_pool_name                = "${local.project}-backend-pool"
  frontend_endpoint_name           = replace(local.frontend_host, ".", "")
  frontend_host                    = "${local.project}.azurefd.net"
}

resource "azurerm_frontdoor" "example" {
  name                                         = local.project
  resource_group_name                          = azurerm_resource_group.example.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    accepted_protocols = ["Http"]
    frontend_endpoints = [local.frontend_endpoint_name]
    name               = "fd-to-lb"
    patterns_to_match  = ["/*"]

    forwarding_configuration {
      forwarding_protocol = "HttpOnly"
      backend_pool_name   = local.backend_pool_name
    }
  }

  backend_pool_load_balancing {
    name = local.backend_pool_load_balancing_name
  }

  backend_pool_health_probe {
    interval_in_seconds = 5
    name                = local.backend_pool_health_probe_name
    probe_method        = "HEAD"
  }

  backend_pool {
    name = local.backend_pool_name
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

