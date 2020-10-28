resource "azurerm_log_analytics_workspace" "diagnostics" {
  name                = "la-${local.project}-${random_pet.fido.id}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}
