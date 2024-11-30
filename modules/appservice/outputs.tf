output "app_service_id" {
  value       = azurerm_linux_web_app.appservice.id  # Corrected resource reference
  description = "The ID of the Linux Web App"
}

# Output the private IP address of the App Service private endpoint
output "appservice_private_ip" {
  value       = azurerm_private_endpoint.appservice_pep.private_service_connection[0].private_ip_address
  description = "The private IP address of the App Service private endpoint"
}
