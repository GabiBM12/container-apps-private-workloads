data "terraform_remote_state" "platform" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.repo2_state_resource_group_name
    storage_account_name = var.repo2_state_storage_account_name
    container_name       = var.repo2_state_container_name
    key                  = var.repo2_state_key
  }
}

resource "azurerm_resource_group" "workload_rg" {
  name     = var.workload_rg_name
  location = var.location
}
locals {
  platform_subnet_ids           = data.terraform_remote_state.platform.outputs.subnet_ids
  platform_private_dns_zone_ids = data.terraform_remote_state.platform.outputs.private_dns_zone_ids

  # The names must match the subnet keys you output in repo #2
  snet_aca_env_id          = local.platform_subnet_ids["snet-aca-env"]
  snet_workloads_id        = local.platform_subnet_ids["snet-workloads"]
  snet_private_enpoints_id = local.platform_subnet_ids["snet-private-endpoints"]
}

resource "azurerm_log_analytics_workspace" "aca" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.workload_rg.location
  resource_group_name = azurerm_resource_group.workload_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.workload_rg.location
  resource_group_name        = azurerm_resource_group.workload_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca.id

  infrastructure_subnet_id       = local.snet_aca_env_id
  internal_load_balancer_enabled = true
}
