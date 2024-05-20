resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space       = ["10.110.0.0/16"]
}

resource "azurerm_subnet" "control_plane_subnet" {
  name                 = "controlPlane"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.110.0.0/21"]
}

resource "azurerm_subnet" "apps_subnet" {
  name                 = "Apps"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.110.8.0/21"]
}

resource "azurerm_subnet" "vms_subnet" {
  name                 = "VMs"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.110.16.0/22"]
}

