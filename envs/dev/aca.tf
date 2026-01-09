resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.workload_rg.location
  resource_group_name        = azurerm_resource_group.workload_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca.id

  infrastructure_subnet_id       = local.snet_aca_env_id
  internal_load_balancer_enabled = false
}
resource "azurerm_container_app" "hello" {
  name                         = "${var.name_prefix}-ca-hello"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.workload_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "hello"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    min_replicas = 0
    max_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = var.tags
}

 