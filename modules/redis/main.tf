resource "azurerm_redis_cache" "redis" {
  name                = lower("${var.redis_name}-${var.resource_suffix}")
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  capacity            = 3 # 6 GB Cache
  family              = "C"
  sku_name            = "Standard"
  non_ssl_port_enabled = true
  public_network_access_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.redis_private_dns_zone_vnet_link]

}

# Private Endpoint for Redis
resource "azurerm_private_endpoint" "redis_pep" {
  name                = var.redis_pep_name
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  subnet_id           = var.subnet_id


  private_service_connection {
    name                           = "redis-private_service_connection"
    private_connection_resource_id = azurerm_redis_cache.redis.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_private_dns_zone.id]
  }

}

resource "azurerm_private_dns_zone" "redis_private_dns_zone" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
}

# Link Private DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "redis_private_dns_zone_vnet_link" {
  name                  = "redis-private-dns-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.redis_private_dns_zone.name
  virtual_network_id    = var.vnet_id  # Pass the VNet ID from the main configuration
  resource_group_name   = lower("${var.resource_group_name}-${var.resource_suffix}")
}