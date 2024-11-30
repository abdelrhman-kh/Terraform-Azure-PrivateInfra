output "app_gateway_id" {
  value       = azurerm_application_gateway.app_gateway.id
  description = "The ID of the Application Gateway"
}

output "app_gateway_frontend_ip" {
  value       = azurerm_public_ip.app_gateway_public_ip.ip_address
  description = "The public IP of the Application Gateway"
}
