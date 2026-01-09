resource "azurerm_log_analytics_workspace" "aca" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.workload_rg.location
  resource_group_name = azurerm_resource_group.workload_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}