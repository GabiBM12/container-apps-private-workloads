terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "gabibtfstate0012"
    container_name       = "tfstate"
    key                  = "container-apps-private-workloads/dev.tfstate"
  }
}