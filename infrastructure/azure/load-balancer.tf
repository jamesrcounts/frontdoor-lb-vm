locals {
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_public_ip" "example" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.example.location
  name                = "pip-${local.project}"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_lb" "example" {
  location            = azurerm_resource_group.example.location
  name                = "lb-${local.project}"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id     = azurerm_lb.example.id
  name                = "BackEndAddressPool"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_lb_probe" "example" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "http-running-probe"
  port                = 80
  protocol            = "HTTP"
  request_path        = "/"
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "web"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.example.id
  probe_id                       = azurerm_lb_probe.example.id
}