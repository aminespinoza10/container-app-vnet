resource "azurerm_container_app_environment" "apps_env" {
  name                           = var.container_app_environment_name
  location                       = var.resource_group_location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  internal_load_balancer_enabled = true
  infrastructure_subnet_id       = var.subnet_id
}

//this image will not be part of the final architecture
resource "azurerm_container_app" "testing_image" {
  name                         = "amines-app"
  container_app_environment_id = azurerm_container_app_environment.apps_env.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = "minimalapi"
      image  = "docker.io/aminespinoza/minimalapi:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    target_port      = 80
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}