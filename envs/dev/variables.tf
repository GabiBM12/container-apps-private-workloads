variable "location" {
  description = " Azure regino for workload resources"
  type        = string
}
variable "workload_rg_name" {
  description = "Resource group for repo #3 workload resources"
  type        = string
}

# Remote state config for Repo #2 Secure Networking Private Access

variable "repo2_state_resource_group_name" {
  description = "Resource group name where repo #2 tfstate is stored"
  type        = string
}
variable "repo2_state_storage_account_name" {
  description = "Storage account name where repo #2 tfstate is stored"
  type        = string
}
variable "repo2_state_container_name" {
  description = "Container name where repo #2 tfstate is stored"
  type        = string
}
variable "repo2_state_key" {
  description = "Key (file name) where repo #2 tfstate is stored"
  type        = string
}