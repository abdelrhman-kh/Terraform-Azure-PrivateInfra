variable "resource_suffix" {
  description = "The unique suffix for appending to resource names"
  type        = string
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the Virtual Network"
}

output "resource_group" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the resource_group"
}

output "subnet_ids" {
  value = {
    for s in azurerm_subnet.subnet : s.name => s.id
  }
}


