resource "azurerm_container_app" "crm" {
  name                         = "${var.name_prefix}-ca-crm"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.workload_rg.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id] # <- SAME UAMI as hello used
  }

  registry {
    server   = local.acr_login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "crm"
      image  = "${local.acr_login_server}/crm-api:0.1.0"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = local.storage_account_name
      }
      env {
        name  = "AZURE_STORAGE_CONTAINER_NAME"
        value = "uploads"
      }
    }
  }
}