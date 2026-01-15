output "workload_resource_group_name" {
  value = azurerm_resource_group.workload_rg.name
}

output "workload_resource_group_id" {
  value = azurerm_resource_group.workload_rg.id
}

# Pass-through outputs from Repo #2 for convenience
output "platform_subnet_ids" {
  value = data.terraform_remote_state.platform.outputs.subnet_ids
}

output "platform_private_dns_zone_ids" {
  value = data.terraform_remote_state.platform.outputs.private_dns_zone_ids
}

output "snet_aca_id" {
  value = local.snet_aca_env_id
}
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.aca.id
}

output "container_app_environment_id" {
  value = azurerm_container_app_environment.this.id
}

output "container_app_environment_default_domain" {
  value = azurerm_container_app_environment.this.default_domain
}

output "container_app_environment_static_ip" {
  value = azurerm_container_app_environment.this.static_ip_address
}
output "gha_client_id" {
  value = azurerm_user_assigned_identity.gha.client_id
}

output "gha_identity_id" {
  value = azurerm_user_assigned_identity.gha.id
}