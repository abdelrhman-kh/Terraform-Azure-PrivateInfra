# Generate random value for the name
resource "random_string" "name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

# Generate random value for the login password
resource "random_password" "password" {
  length           = 8
  lower            = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}

# Private DNS Zone for MySQL
resource "azurerm_private_dns_zone" "mysql_private_dns_zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
}

# Link Private DNS Zone to Virtual Network (only one link is needed)
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_private_dns_zone_vnet_link" {
  name                  = "mysql-private-dns-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = lower("${var.resource_group_name}-${var.resource_suffix}")
}

# MySQL Flexible Server (Primary)
resource "azurerm_mysql_flexible_server" "mysql_server" {
  name                   = lower("${var.mysql_name}-${var.resource_suffix}")
  location               = var.location
  resource_group_name    = lower("${var.resource_group_name}-${var.resource_suffix}")
  administrator_login    = random_string.name.result
  administrator_password = random_password.password.result
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_private_dns_zone.id
  delegated_subnet_id    = var.subnet_id
  backup_retention_days  = 7
  sku_name               = "GP_Standard_D2ds_v4"
  version                = "8.0.21"

  storage {
    size_gb            = 100
    auto_grow_enabled  = true
    io_scaling_enabled = false
    iops               = 1000
  }

  high_availability {
    mode = "SameZone"
  }

  tags = {
    environment = "production"
    environment2 = "production2"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_private_dns_zone_vnet_link]
}

# Disable require_secure_transport for Primary
resource "azurerm_mysql_flexible_server_configuration" "mysql_disable_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = azurerm_mysql_flexible_server.mysql_server.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
  value               = "OFF"

  depends_on = [azurerm_mysql_flexible_server.mysql_server]
}

# Run Azure CLI command to set up replication
resource "null_resource" "mysql_replication_setup" {
  provisioner "local-exec" {
    command = <<EOT
      az mysql flexible-server replica create --replica-name ${lower("${var.mysql_replica_name}-${var.resource_suffix}")} --source-server ${azurerm_mysql_flexible_server.mysql_server.name} --resource-group ${lower("${var.resource_group_name}-${var.resource_suffix}")} --location ${var.location}
    EOT
  }

  # Ensure this runs after both primary and replica are created
  depends_on = [
    azurerm_mysql_flexible_server.mysql_server,
    azurerm_mysql_flexible_server_configuration.mysql_disable_secure_transport
  ]
}