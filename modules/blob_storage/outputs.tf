output "storage_account_name" {
  value       = azurerm_storage_account.storage_account.name
  description = "The name of the storage account."
}

output "blob_container_name" {
  value       = azurerm_storage_container.blob_container.name
  description = "The name of the blob container."
}

output "storage_account_primary_connection_string" {
  value       = azurerm_storage_account.storage_account.primary_connection_string
  description = "The primary connection string for the storage account."
}

output "blob_private_dns_zone_id" {
  value       = azurerm_private_dns_zone.blob_private_dns_zone.id
  description = "The ID of the private DNS zone for Blob Storage."
}

output "storage_account_primary_key" {
  value       = azurerm_storage_account.storage_account.primary_access_key
  description = "The primary access key for the storage account."
}

output "storage_account_secondary_key" {
  value       = azurerm_storage_account.storage_account.secondary_access_key
  description = "The secondary access key for the storage account."
}
