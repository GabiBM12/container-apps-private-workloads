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
  acr_id                        = data.terraform_remote_state.platform.outputs.acr_id
  acr_login_server              = data.terraform_remote_state.platform.outputs.acr_login_server
  keyvault_id                   = data.terraform_remote_state.platform.outputs.keyvault_id
  storage_account_id            = data.terraform_remote_state.platform.outputs.storage_account_id

  # The names must match the subnet keys you output in repo #2
  snet_aca_env_id          = local.platform_subnet_ids["snet-aca-env"]
  snet_workloads_id        = local.platform_subnet_ids["snet-workloads"]
  snet_private_enpoints_id = local.platform_subnet_ids["snet-private-endpoints"]
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.name_prefix}-id-crm"
  location            = azurerm_resource_group.workload_rg.location
  resource_group_name = azurerm_resource_group.workload_rg.name
  tags                = var.tags
}



