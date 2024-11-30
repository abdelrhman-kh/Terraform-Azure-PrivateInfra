# Public IP for Application Gateway
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "${var.app_gateway_name}-public-ip"
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway with HTTPS configuration
resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  
  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "app_gateway_ip_config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "app_gateway_frontend_ip"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  frontend_port {
    name = "app_gateway_https_frontend_port"
    port = 443
  }

  backend_address_pool {
    name         = "app_gateway_backend_pool"
    ip_addresses = [var.appservice_private_ip]
  }

  # SSL certificate block within the application gateway
  ssl_certificate {
    name     = "app_gateway_ssl_cert"
    data     = filebase64(var.ssl_cert_path)  # Path to the .pfx file for SSL
    password = var.ssl_cert_password
  }

  http_listener {
    name                           = "app_gateway_https_listener"
    frontend_ip_configuration_name = "app_gateway_frontend_ip"
    frontend_port_name             = "app_gateway_https_frontend_port"
    protocol                       = "Https"
    ssl_certificate_name           = "app_gateway_ssl_cert"
  }

  backend_http_settings {
    name                  = "app_gateway_https_setting"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    host_name             = lower("${var.hostname_backend_setting}-${var.resource_suffix}.azurewebsites.net")
  }

  request_routing_rule {
    name                       = "app_gateway_https_routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = "app_gateway_https_listener"
    backend_address_pool_name  = "app_gateway_backend_pool"
    backend_http_settings_name = "app_gateway_https_setting"
    priority                   = 100
  }

}
