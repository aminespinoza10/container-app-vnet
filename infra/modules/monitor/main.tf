resource "azurerm_application_insights" "application_insights" {
  name                = var.application_insights_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}