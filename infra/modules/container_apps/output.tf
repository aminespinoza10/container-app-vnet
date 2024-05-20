output "env_default_domain" {
  value = azurerm_container_app_environment.apps_env.default_domain
}

output "env_ip" {
  value = azurerm_container_app_environment.apps_env.static_ip_address
}

output "container_app_url" {
  value = azurerm_container_app.testing_image.ingress[0].fqdn
}