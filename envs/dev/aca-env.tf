resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.workload_rg.location
  resource_group_name        = azurerm_resource_group.workload_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca.id

  infrastructure_subnet_id       = local.snet_aca_env_id
  internal_load_balancer_enabled = false
}


 