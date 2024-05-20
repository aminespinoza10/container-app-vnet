resource "azurecaf_name" "rg_name" {
  name          = "facturaAPI"
  resource_type = "azurerm_resource_group"
  prefixes      = ["dev"]
  random_length = 3
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = var.resource_group_location
}

resource "azurecaf_name" "vnet_name" {
  name          = "facturaapi"
  resource_type = "azurerm_virtual_network"
  prefixes      = ["dev"]
  random_length = 3
  clean_input   = true
}

module "vnet" {
  source                  = "./modules/vnet"
  vnet_name               = azurecaf_name.vnet_name.result
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
}

resource "azurecaf_name" "app_insights_name" {
  name          = "facturaapi"
  resource_type = "azurerm_application_insights"
  prefixes      = ["dev"]
  random_length = 3
  clean_input   = true
}

resource "azurecaf_name" "log_analytics_name" {
  name          = "facturaapi"
  resource_type = "azurerm_log_analytics_workspace"
  prefixes      = ["dev"]
  random_length = 3
  clean_input   = true
}

module "monitor" {
  source                       = "./modules/monitor"
  resource_group_name          = azurerm_resource_group.rg.name
  resource_group_location      = azurerm_resource_group.rg.location
  application_insights_name    = azurecaf_name.app_insights_name.result
  log_analytics_workspace_name = azurecaf_name.log_analytics_name.result
}

module "container_apps" {
  source                         = "./modules/container_apps"
  container_app_environment_name = "container-app-environment"
  resource_group_name            = azurerm_resource_group.rg.name
  resource_group_location        = azurerm_resource_group.rg.location
  log_analytics_workspace_id     = module.monitor.log_analytics_workspace_id
  subnet_id                      = module.vnet.control_plane_subnet_id
}

module "dns_private_zone" {
  source                     = "./modules/dns"
  dns_zone_name              = module.container_apps.env_default_domain
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_id         = module.vnet.virtual_network_id
  app_environment_ip_address = module.container_apps.env_ip
}


resource "azurecaf_name" "virtual_machine_name" {
  name          = "facturaapi"
  resource_type = "azurerm_virtual_machine"
  prefixes      = ["dev"]
  random_length = 3
  clean_input   = true
}

module "vm" {
  source               = "./modules/vm"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  vm_subnet_id         = module.vnet.vm_subnet_id
  virtual_machine_name = azurecaf_name.virtual_machine_name.result
}


resource "azurecaf_name" "api_management_name" {
  name          = "facturaapi"
  resource_type = "azurerm_api_management_service"
  prefixes      = ["dev"]
  random_length = 3
  clean_input   = true
}

module "api_management" {
  source              = "./modules/apim"
  api_management_name = azurecaf_name.api_management_name.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = module.vnet.apps_subnet_id
  container_app_url   = module.container_apps.container_app_url
}