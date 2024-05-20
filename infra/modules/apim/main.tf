resource "azurerm_network_security_group" "apim-nsg" {
  name                = "nsg-apim"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "apim-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "apim-nsg-association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.apim-nsg.id
}


resource "azurerm_api_management" "api_management" {
  name                 = var.api_management_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  publisher_name       = "Mas Factura"
  publisher_email      = "admin@masfactura.com"
  sku_name             = var.api_management_sku
  virtual_network_type = var.network_type

  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_api" "internal_api" {
  name                  = "internal-api"
  resource_group_name   = var.resource_group_name
  api_management_name   = azurerm_api_management.api_management.name
  revision              = "1"
  display_name          = "Internal API"
  path                  = ""
  protocols             = ["https"]
  service_url           = "https://${var.container_app_url}"
  subscription_required = false
}

