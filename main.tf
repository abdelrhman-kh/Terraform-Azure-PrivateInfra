# Generate a unique suffix
resource "random_string" "unique_suffix" {
  length  = 6
  special = false
}

# Call the network module
module "network" {
  source  = "./modules/network"

  # Pass the random string result as resource_suffix
  resource_suffix = random_string.unique_suffix.result
}


# Fetch the suffixed subnet names dynamically
locals {
  appservice_subnet_id          = module.network.subnet_ids["snet-dcai-prod-app-uaen-001-${random_string.unique_suffix.result}"]
  db_subnet_id                  = module.network.subnet_ids["snet-dcai-prod-db-uaen-001-${random_string.unique_suffix.result}"]
  cache_subnet_id               = module.network.subnet_ids["snet-dcai-prod-cache-uaen-001-${random_string.unique_suffix.result}"]
  storage_subnet_id             = module.network.subnet_ids["snet-dcai-prod-storage-uaen-001-${random_string.unique_suffix.result}"]
  application_gateway_subnet_id = module.network.subnet_ids["snet-dcai-prod-app-gate-uaen-001-${random_string.unique_suffix.result}"]
  appservice_private_ip         = module.appservice.appservice_private_ip
  app_service_name              = "web-dcai-prod-uaen"
}

module "appservice" {
  source    = "./modules/appservice"
  subnet_id = local.appservice_subnet_id

  app_service_plan_name = "asp-dcai-prod-uaen"
  app_service_name      = local.app_service_name
  
  # Pass the random string result as resource_suffix
  resource_suffix = random_string.unique_suffix.result

  # Pass necessary variables from network module to appservice module
  subnet_ids = module.network.subnet_ids

  # Pass the MySQL server name, Redis hostname, and Redis primary access key
  mysql_server_name             = module.mysql.mysql_server_name
  mysql_server_admin_login      = module.mysql.admin_login
  mysql_server_admin_password   = module.mysql.admin_password
  redis_hostname                = module.redis.redis_hostname
  redis_primary_access_key      = module.redis.redis_primary_access_key

  # Pass storage-related variables from blob_storage module
  storage_account_key           = module.blob_storage.storage_account_primary_key
  storage_account_name          = module.blob_storage.storage_account_name
  blob_container_name           = module.blob_storage.blob_container_name

  # Combine all the dependencies into one depends_on block
  depends_on = [module.network, module.mysql, module.redis , module.blob_storage]
}


# Call the MySQL module
module "mysql" {
  source    = "./modules/db"
  subnet_id = local.db_subnet_id

  mysql_name              = "mysql-dcai-prod-uaen-001"
  mysql_replica_name      = "mysql-dcai-prod-uaen-002"

  # Pass the random string result as resource_suffix
  resource_suffix = random_string.unique_suffix.result

  # Pass the vnet_id to the mysql module
  vnet_id = module.network.vnet_id

  depends_on = [module.network]
}

# Call the Redis module
module "redis" {
  source    = "./modules/redis"
  subnet_id = local.cache_subnet_id

  redis_name = "cache-dcai-prod-uaen"

  # Pass the random string result as resource_suffix
  resource_suffix = random_string.unique_suffix.result

  # Pass the vnet_id to the mysql module
  vnet_id = module.network.vnet_id

  depends_on = [module.network]
}

# Call the Blob Storage module
module "blob_storage" {
  source          = "./modules/blob_storage"

  # Pass the random string result as resource_suffix
  resource_suffix = random_string.unique_suffix.result
  subnet_id       = local.storage_subnet_id

  depends_on = [module.network]
}

module "application_gateway" {
  source              = "./modules/application_gateway"
  app_gateway_name    = "gateway-dcai-prod-uaen-001"
  subnet_id           = local.application_gateway_subnet_id

  # Pass the random string result as resource_suffix
  resource_suffix = random_string.unique_suffix.result

  # Pass the private IP from the appservice module
  appservice_private_ip = module.appservice.appservice_private_ip

  hostname_backend_setting = local.app_service_name

  # SSL certificate variables
  ssl_cert_path       = "./cert/dff-stage.meemdev.com.pfx"
  ssl_cert_password   = "P@ssw0rd"

  depends_on = [module.network , module.appservice]
}