output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "control_plane_subnet_id" {
  value = azurerm_subnet.control_plane_subnet.id
}

output "apps_subnet_id" {
  value = azurerm_subnet.apps_subnet.id
}

output "vm_subnet_id" {
  value = azurerm_subnet.vms_subnet.id
}