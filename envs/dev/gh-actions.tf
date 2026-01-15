resource "azurerm_user_assigned_identity" "gha" {
  name                = "uami-${var.name_prefix}-gha"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload_rg.name
  tags                = var.tags
}
resource "azurerm_role_assignment" "gha_acr_push" {
  scope                = local.acr_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.gha.principal_id
}
resource "azurerm_role_assignment" "gha_workloads_contributor" {
  scope                = azurerm_resource_group.workload_rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.gha.principal_id
}