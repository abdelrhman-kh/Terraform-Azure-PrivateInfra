# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = lower("${var.resource_group_name}-${var.resource_suffix}")
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = lower("${var.vnet_name}-${var.resource_suffix}")
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnets
resource "azurerm_subnet" "subnet" {
  for_each            = var.subnets
  name                = "${each.value.name}-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = [each.value.address_prefix]

  # Conditionally add delegation to the "appservice" subnet
  dynamic "delegation" {
    for_each = each.key == "appservice" ? [1] : []
    content {
      name = "delegation-appservice"
      service_delegation {
        name = "Microsoft.Web/serverFarms"
      }
    }
  }

  # Conditionally add delegation to the "db" subnet
  dynamic "delegation" {
    for_each = each.key == "db" ? [1] : []
    content {
      name = "delegation-db"
      service_delegation {
        name = "Microsoft.DBforMySQL/flexibleServers"
      }
    }
  }

}
