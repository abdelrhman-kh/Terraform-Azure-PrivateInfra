# Create a Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob_private_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
}

# Create a Storage Account with Versioning and Data Protection
resource "azurerm_storage_account" "storage_account" {
  name                     = lower("${var.storage_account_name}${var.resource_suffix}")
  resource_group_name      = lower("${var.resource_group_name}-${var.resource_suffix}")
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  access_tier              = "Hot"

  # Data Protection Settings for Blobs
  blob_properties {
    versioning_enabled            = true  # Enable versioning for blobs
    change_feed_enabled           = true  # Enable change feed for tracking changes in blobs
    delete_retention_policy {
      days = 7                     # Enable soft delete for blobs, keep deleted blobs for 7 days
    }
    container_delete_retention_policy {
      days = 7                     # Enable soft delete for containers, keep deleted containers for 7 days
    }
  }

  # Provisioner to enable Point-in-Time Restore using Azure CLI
  provisioner "local-exec" {
    command = <<EOT
      az storage account blob-service-properties update --resource-group ${lower("${var.resource_group_name}-${var.resource_suffix}")} --account-name ${azurerm_storage_account.storage_account.name} --enable-delete-retention true --delete-retention-days 14 --enable-versioning true --enable-change-feed true --enable-restore-policy true --restore-days 7
    EOT
}

  # Ensure execution order with depends_on, only for DNS Zone
  depends_on = [
    azurerm_private_dns_zone.blob_private_dns_zone
  ]
}

# Create a Blob Container in the Storage Account
resource "azurerm_storage_container" "blob_container" {
  name                  = lower("${var.container_name}${var.resource_suffix}")
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

# Create a Private Endpoint for the Storage Account
resource "azurerm_private_endpoint" "blob_storage_private_endpoint" {
  name                = lower("${var.storage_account_pep_name}-${var.resource_suffix}")
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  subnet_id           = var.subnet_id # Subnet for the private endpoint

  private_service_connection {
    name                           = "blob-private-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob-storage-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_private_dns_zone.id]
  }
}
