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

output "snet_container_apps_id" {
  value = local.snet_container_apps_id
}